const IPP_IO_CSV = joinpath(@__DIR__, "..", "csv", "software_io_remapping.csv")
const IPP_MATRIX_CSV = joinpath(@__DIR__, "..", "csv", "ipp_io_matrix.csv")
const IPP_CAPITALIZATION_CSV = joinpath(@__DIR__, "..", "csv", "ipp_capitalization_benchmark.csv")
const IPP_PRE1999_CSV = joinpath(@__DIR__, "..", "csv", "pre1999_bridge_benchmark.csv")

function ipp_read_io(path::AbstractString=IPP_IO_CSV)
    raw, header = readdlm(path, ',', Any, '\n'; header=true)
    names = strip.(string.(vec(header)))
    expected = ["Year", "IntermediateInputsAfter", "ValueAddedAfter", "GrossOutputAfter",
                "PurchasedSoftware", "OwnAccountSoftware", "SoftwareInvestmentAfter",
                "IntermediateInputsBefore", "ValueAddedBefore", "GrossOutputBefore"]
    names == expected || error("Unexpected schema in $(path).")
    (; years=Int.(raw[:, 1]), raw)
end

# Benchmark-year reconstruction. Business own-account R&D is inferred from
# secondary private-industry R&D production less published NPISH R&D.
function ipp_pre1999_values(year::Integer=2017; path::AbstractString=IPP_PRE1999_CSV)
    raw, header = readdlm(path, ',', Any, '\n'; header=true)
    names = strip.(string.(vec(header)))
    years = Int.(raw[:, findfirst(==("Year"), names)])
    row = only(findall(==(year), years))
    value(name) = Float64(raw[row, only(findall(==(name), names))])
    current_go=value("CurrentGrossOutput"); current_intermediate=value("CurrentIntermediate")
    current_va=value("CurrentValueAdded"); current_final=value("CurrentFinalDemand")
    current_use=value("CurrentTotalUse"); software=value("Software")
    own_software=value("OwnAccountSoftware"); purchased_software=value("PurchasedSoftware")
    business_rd=value("BusinessRD"); npish_rd=value("NPISHRD")
    private_secondary_rd=value("PrivateSecondaryRD")
    own_business_rd=private_secondary_rd-npish_rd
    purchased_business_rd=business_rd-own_business_rd
    artistic=value("ArtisticOriginals"); npish_cfc=value("NPISHDepreciation")
    government_software=value("GovernmentSoftware"); government_rd=value("GovernmentRD")
    government_cfc=value("GovernmentDepreciation"); imports=value("Imports")
    cif_fob_adjustment=value("CIFFOBAdjustment"); import_duties=value("ImportDuties")
    taxes_on_products=value("TaxesOnProducts"); subsidies=value("Subsidies")
    business_ipp=software+business_rd+artistic
    own_business=own_software+own_business_rd+artistic
    old_go=current_go-own_business-npish_cfc-government_cfc
    old_intermediate=current_intermediate+purchased_software+purchased_business_rd
    old_va=current_va-business_ipp-npish_cfc-government_cfc
    old_use=current_use-own_business-npish_cfc-government_cfc
    old_final=current_final-business_ipp-npish_cfc-government_cfc
    (; year,current_go,current_intermediate,current_va,current_final,current_use,software,
       own_software,purchased_software,business_rd,own_business_rd,purchased_business_rd,
       artistic,npish_rd,npish_cfc,government_software,government_rd,government_cfc,
       imports,cif_fob_adjustment,import_duties,taxes_on_products,subsidies,
       business_ipp,own_business,old_go,old_intermediate,old_va,old_use,old_final)
end

function ipp_pre1999_years(path::AbstractString=IPP_PRE1999_CSV)
    raw, header = readdlm(path, ',', Any, '\n'; header=true)
    names = strip.(string.(vec(header)))
    sort(Int.(raw[:, findfirst(==("Year"), names)]))
end

function ipp_bridge_cells(value, denominator)
    @htl("""<td class="level">$(ipp_money(value))</td><td class="share">$(round(100value/denominator; digits=1))</td>""")
end

function ipp_pre1999_rd_method_note()
    @htl("""<div style="font-size:.8rem;color:#444;margin-top:.35rem"><b>Estimated R&amp;D split:</b>
    Business own-account R&amp;D is not a directly published line in this table. It is estimated as private-industry
    secondary production of R&amp;D services less NPISH R&amp;D. Purchased business R&amp;D is the residual from published
    total business R&amp;D investment. This calculation assumes that private secondary R&amp;D production represents
    own-account production and that the NPISH amount should be removed from it.</div>""")
end

function ipp_bridge_title(title::AbstractString, year::Integer, show_title::Bool)
    show_title || return @htl("")
    @htl("""<div style="text-align:center;margin-bottom:.6rem"><b style="font-size:1.2rem">$(title)</b><div>$(year), current-dollar billions</div></div>""")
end

function ipp_pre1999_total_input_html(year::Integer=2017; show_title::Bool=true)
    v=ipp_pre1999_values(year); c(x)=ipp_bridge_cells(x,v.old_go)
    title = ipp_bridge_title("Total Input Remapping: Current Concepts to Pre-1999 Concepts", v.year, show_title)
    @htl("""
    <div class="ipp-bridge-wrap"><style>
      .ipp-bridge-wrap{max-width:980px;margin:0 auto;font-family:system-ui,sans-serif}.ipp-bridge{border-collapse:collapse;width:100%}
      .ipp-bridge th,.ipp-bridge td{padding:7px 11px;border-bottom:1px solid #ddd}.ipp-bridge th{text-align:left;border-top:2px solid #999;border-bottom:2px solid #999}
      .ipp-bridge .level,.ipp-bridge .share{text-align:right;font-variant-numeric:tabular-nums}.ipp-bridge .result{font-weight:750;border-bottom:1px solid #999}
      .ipp-bridge .account{vertical-align:top;font-family:serif;font-size:1.05rem;width:15%}
      .ipp-bridge th:first-child,.ipp-bridge td.account{display:none}
    </style>$(title)
    <table class="ipp-bridge"><thead><tr><th>Account</th><th>Construction from current input–output accounts</th><th style="text-align:right">Level</th><th style="text-align:right">%GO</th></tr></thead><tbody>
      <tr><td rowspan="7" class="account">Gross output</td><td><b>Current gross output</b></td>$(c(v.current_go))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, software, own account</td>$(c(v.own_software))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, R&amp;D, business, own-account portion</td>$(c(v.own_business_rd))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, artistic originals</td>$(c(v.artistic))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed assets, R&amp;D, NPISH, depreciation</td>$(c(v.npish_cfc))</tr>
      <tr><td style="padding-left:30px">Less: Government fixed assets, IPP, depreciation</td>$(c(v.government_cfc))</tr>
      <tr class="result"><td>= Pre-1999 gross output</td>$(c(v.old_go))</tr>
      <tr><td rowspan="4" class="account">Intermediate inputs</td><td><b>Current intermediate inputs</b></td>$(c(v.current_intermediate))</tr>
      <tr><td style="padding-left:30px">Plus: Private fixed investment, software, prepackaged and custom</td>$(c(v.purchased_software))</tr>
      <tr><td style="padding-left:30px">Plus: Private fixed investment, R&amp;D, business, purchased portion</td>$(c(v.purchased_business_rd))</tr>
      <tr class="result"><td>= Pre-1999 intermediate inputs</td>$(c(v.old_intermediate))</tr>
      <tr><td rowspan="7" class="account">Value added</td><td><b>Current value added</b></td>$(c(v.current_va))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, software</td>$(c(v.software))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, R&amp;D, business</td>$(c(v.business_rd))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, artistic originals</td>$(c(v.artistic))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed assets, R&amp;D, NPISH, depreciation</td>$(c(v.npish_cfc))</tr>
      <tr><td style="padding-left:30px">Less: Government fixed assets, IPP, depreciation</td>$(c(v.government_cfc))</tr>
      <tr class="result"><td>= Pre-1999 value added</td>$(c(v.old_va))</tr>
    </tbody></table><div style="font-size:.8rem;color:#444;margin-top:.7rem">Shares use reconstructed pre-1999 gross output as the denominator. Intermediate inputs plus value added equal gross output, apart from published-detail rounding.</div>$(ipp_pre1999_rd_method_note())</div>""")
end

function ipp_pre1999_total_output_html(year::Integer=2017; show_title::Bool=true)
    v=ipp_pre1999_values(year); c(x)=ipp_bridge_cells(x,v.old_use)
    title = ipp_bridge_title("Total Output Remapping: Current Concepts to Pre-1999 Concepts", v.year, show_title)
    @htl("""
    <div class="ipp-bridge-wrap"><style>
      .ipp-bridge-wrap{max-width:980px;margin:0 auto;font-family:system-ui,sans-serif}.ipp-bridge{border-collapse:collapse;width:100%}
      .ipp-bridge th,.ipp-bridge td{padding:7px 11px;border-bottom:1px solid #ddd}.ipp-bridge th{text-align:left;border-top:2px solid #999;border-bottom:2px solid #999}
      .ipp-bridge .level,.ipp-bridge .share{text-align:right;font-variant-numeric:tabular-nums}.ipp-bridge .result{font-weight:750;border-bottom:1px solid #999}
      .ipp-bridge .account{vertical-align:top;font-family:serif;font-size:1.05rem;width:15%}
      .ipp-bridge th:first-child,.ipp-bridge td.account{display:none}
    </style>$(title)
    <table class="ipp-bridge"><thead><tr><th>Account</th><th>Construction from current input–output accounts</th><th style="text-align:right">Level</th><th style="text-align:right">% total</th></tr></thead><tbody>
      <tr><td rowspan="7" class="account">Total use</td><td><b>Current total use of products</b></td>$(c(v.current_use))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, software, own account</td>$(c(v.own_software))</tr><tr><td style="padding-left:30px">Less: Private fixed investment, R&amp;D, business, own-account portion</td>$(c(v.own_business_rd))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, artistic originals</td>$(c(v.artistic))</tr><tr><td style="padding-left:30px">Less: Private fixed assets, R&amp;D, NPISH, depreciation</td>$(c(v.npish_cfc))</tr><tr><td style="padding-left:30px">Less: Government fixed assets, IPP, depreciation</td>$(c(v.government_cfc))</tr>
      <tr class="result"><td>= Pre-1999 total use</td>$(c(v.old_use))</tr>
      <tr><td rowspan="4" class="account">Intermediate use</td><td><b>Current intermediate use</b></td>$(c(v.current_intermediate))</tr><tr><td style="padding-left:30px">Plus: Private fixed investment, software, prepackaged and custom</td>$(c(v.purchased_software))</tr><tr><td style="padding-left:30px">Plus: Private fixed investment, R&amp;D, business, purchased portion</td>$(c(v.purchased_business_rd))</tr><tr class="result"><td>= Pre-1999 intermediate use</td>$(c(v.old_intermediate))</tr>
      <tr><td rowspan="14" class="account">Final demand</td><td><b>Current final demand</b></td>$(c(v.current_final))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, software</td>$(c(v.software))</tr><tr><td style="padding-left:30px">Less: Private fixed investment, R&amp;D, business</td>$(c(v.business_rd))</tr><tr><td style="padding-left:30px">Less: Private fixed investment, artistic originals</td>$(c(v.artistic))</tr>
      <tr><td style="padding-left:30px">Less: Private fixed investment, R&amp;D, NPISH</td>$(c(v.npish_rd))</tr><tr><td style="padding-left:30px">Plus: Personal consumption expenditures, NPISH R&amp;D</td>$(c(v.npish_rd))</tr><tr><td style="padding-left:30px">Less: Personal consumption expenditures, NPISH IPP depreciation</td>$(c(v.npish_cfc))</tr>
      <tr><td style="padding-left:30px">Less: Gross government fixed investment, software</td>$(c(v.government_software))</tr><tr><td style="padding-left:30px">Less: Gross government fixed investment, R&amp;D</td>$(c(v.government_rd))</tr><tr><td style="padding-left:30px">Plus: Government consumption expenditures, software</td>$(c(v.government_software))</tr><tr><td style="padding-left:30px">Plus: Government consumption expenditures, R&amp;D</td>$(c(v.government_rd))</tr><tr><td style="padding-left:30px">Less: Government consumption expenditures, IPP depreciation</td>$(c(v.government_cfc))</tr>
      <tr class="result"><td>= Pre-1999 final demand</td>$(c(v.old_final))</tr>
    </tbody></table><div style="font-size:.8rem;color:#444;margin-top:.7rem">Government and NPISH expenditures remain in final demand; their investment-to-consumption reclassifications cancel. The net reductions are their IPP depreciation amounts.</div>$(ipp_pre1999_rd_method_note())</div>""")
end

function ipp_total_use_gross_output_html(year::Integer=2017; show_title::Bool=true)
    v=ipp_pre1999_values(year); c(x)=ipp_bridge_cells(x,v.current_use)
    bridge_gap = abs(v.current_use-v.imports+(-v.cif_fob_adjustment)-v.import_duties-v.taxes_on_products+v.subsidies-v.current_go)
    title = ipp_bridge_title("Relation of Total Use of Products and Gross Output", v.year, show_title)
    @htl("""
    <div class="ipp-bridge-wrap"><style>
      .ipp-bridge-wrap{max-width:980px;margin:0 auto;font-family:system-ui,sans-serif}.ipp-bridge{border-collapse:collapse;width:100%}
      .ipp-bridge th,.ipp-bridge td{padding:7px 11px;border-bottom:1px solid #ddd}.ipp-bridge th{text-align:left;border-top:2px solid #999;border-bottom:2px solid #999}
      .ipp-bridge .level,.ipp-bridge .share{text-align:right;font-variant-numeric:tabular-nums}.ipp-bridge .result{font-weight:750;border-bottom:1px solid #999}
      .ipp-bridge th:first-child{display:none}
    </style>$(title)
    <table class="ipp-bridge"><thead><tr><th>Account</th><th>Relation between purchasers’ prices and domestic gross output</th><th style="text-align:right">Level</th><th style="text-align:right">% total use</th></tr></thead><tbody>
      <tr><td><b>Current total use of products</b></td>$(c(v.current_use))</tr>
      <tr><td style="padding-left:30px">Less: Imports</td>$(c(v.imports))</tr>
      <tr><td style="padding-left:30px">Plus: CIF/FOB adjustment on imports</td>$(c(-v.cif_fob_adjustment))</tr>
      <tr><td style="padding-left:30px">Less: Import duties</td>$(c(v.import_duties))</tr>
      <tr><td style="padding-left:30px">Less: Taxes on products</td>$(c(v.taxes_on_products))</tr>
      <tr><td style="padding-left:30px">Plus: Subsidies</td>$(c(v.subsidies))</tr>
      <tr class="result"><td>= Current gross output</td>$(c(v.current_go))</tr>
    </tbody></table><div style="font-size:.8rem;color:#444;margin-top:.7rem">Total use is measured at purchasers’ prices and includes imported products. Removing imports and the net import and product-tax valuation adjustments yields domestic gross output at basic prices. The published detailed totals differ by $(round(bridge_gap; digits=3)) billion because of rounding.</div></div>""")
end

function ipp_pre1999_tables_html(year::Integer=2017; show_title::Bool=true)
    @htl("""<div>$(ipp_pre1999_total_input_html(year; show_title))<div style="height:1.5rem"></div>$(ipp_pre1999_total_output_html(year; show_title))<div style="height:1.5rem"></div>$(ipp_total_use_gross_output_html(year; show_title))</div>""")
end

function ipp_pre1999_selector_preview_html()
    years = ipp_pre1999_years()
    panels = [@htl("""<div class="ipp-year-panel" data-year="$(year)" style="display:$(year == last(years) ? "block" : "none")">$(ipp_pre1999_tables_html(year))</div>""") for year in years]
    @htl("""<div class="ipp-year-preview"><label style="font-family:system-ui,sans-serif;font-weight:650">Benchmark year:
      <select onchange="this.closest('.ipp-year-preview').querySelectorAll('.ipp-year-panel').forEach(p => p.style.display = p.dataset.year === this.value ? 'block' : 'none')">
        $([@htl("""<option value="$(year)" selected=$(year == last(years))>$(year)</option>""") for year in years])
      </select></label><div style="height:.8rem"></div>$(panels)</div>""")
end

function ipp_read_matrix(path::AbstractString=IPP_MATRIX_CSV)
    raw, header = readdlm(path, ',', Any, '\n'; header=true)
    names = strip.(string.(vec(header)))
    expected = ["Year", "Row", "IPPIndustries", "OtherIndustries",
                "IPPFinalDemand", "OtherFinalDemand", "TotalUse"]
    names == expected || error("Unexpected schema in $(path).")
    (; years=sort!(unique(Int.(raw[:, 1]))), raw)
end

function ipp_benchmark_matrix_html(year::Integer=2017; path::AbstractString=IPP_MATRIX_CSV)
    data = ipp_read_matrix(path)
    year in data.years || error("Benchmark year $(year) not found in $(path).")
    selected = data.raw[Int.(data.raw[:, 1]) .== year, :]
    labels = string.(selected[:, 2])
    values = Float64.(selected[:, 3:end])
    function matrixrow(label; strong=false, spacer=false)
        i = only(findall(==(label), labels))
        cells = [@htl("<td class='num'>$(ipp_money(x))</td>") for x in values[i, :]]
        @htl("""<tr class=$(strong ? "total" : "") style=$(spacer ? "border-top:6px solid white" : "")>
            <td>$(label)</td>$(cells)</tr>""")
    end
    @htl("""
    <div style="max-width:1050px;margin:0 auto;font-family:system-ui,sans-serif">
      <style>
        .ipp-matrix{border-collapse:collapse;width:100%;font-size:.91rem}
        .ipp-matrix th,.ipp-matrix td{padding:.55rem .62rem;border-bottom:1px solid #d8dce2}
        .ipp-matrix th{text-align:right;vertical-align:bottom}.ipp-matrix th:first-child{text-align:left}
        .ipp-matrix .num{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}
        .ipp-matrix .total{font-weight:720;border-top:2px solid #555}
        .ipp-matrix .ipp-cell{background:#eef5fc}
        .ipp-matrix-note{margin-top:.75rem;color:#444;font-size:.8rem;line-height:1.4}
      </style>
      <div style="text-align:center;margin-bottom:.65rem">
        <div style="font-size:1.2rem;font-weight:750">U.S. Input–Output Use Matrix: IPP and Non-IPP Aggregates</div>
        <div>Benchmark year $(year), current-dollar billions</div>
      </div>
      <table class="ipp-matrix">
        <thead><tr>
          <th>Commodity supplied \\ Industry or final user</th>
          <th class="ipp-cell">IPP-producing<br>industries</th><th>Other<br>industries</th>
          <th class="ipp-cell">IPP final<br>demand</th><th>Other final<br>demand</th><th>Total<br>use</th>
        </tr></thead>
        <tbody>
          $(matrixrow("IPP-related commodities"))
          $(matrixrow("Non-IPP commodities"))
          $(matrixrow("Intermediate inputs"; strong=true))
          $(matrixrow("Value added"; spacer=true))
          $(matrixrow("Gross output"; strong=true))
        </tbody>
      </table>
      <div class="ipp-matrix-note">
        IPP-producing industries and related commodities comprise software publishing; motion picture and video;
        sound recording; scientific R&amp;D services; and independent artists, writers, and performers.
        IPP final demand is BEA's private, federal, and state-and-local gross investment in intellectual property products.
        Source: BEA detailed benchmark Use Tables (Supply–Use Framework). Detail may differ slightly from totals because of rounding.
      </div>
    </div>""")
end

ipp_money(x) = replace(string(round(Int, x)), r"(?<=\d)(?=(\d{3})+(?!\d))" => ",")
ipp_display(x) = ismissing(x) ? "—" : ipp_money(x)

function ipp_read_capitalization(path::AbstractString=IPP_CAPITALIZATION_CSV)
    raw, header = readdlm(path, ',', Any, '\n'; header=true)
    names = strip.(string.(vec(header)))
    expected = ["Year", "IOTotalIPP", "IOPrivateIPP", "IOGovernmentIPP",
                "NIPAPrivateIPP", "Software", "PurchasedSoftware", "OwnAccountSoftware",
                "ResearchDevelopment", "ArtisticOriginals", "GovernmentSoftware",
                "GovernmentResearchDevelopment", "SoftwareAllSectors",
                "ResearchDevelopmentAllSectors", "OtherIPPAllSectors",
                "PrivateReconciliationDifference"]
    names == expected || error("Unexpected schema in $(path).")
    (; years=Int.(raw[:, 1]), raw)
end

function ipp_capitalization_reconciliation_html(year::Integer=2017; path::AbstractString=IPP_CAPITALIZATION_CSV)
    data = ipp_read_capitalization(path)
    i = only(findall(==(year), data.years))
    total, private_io, government, private_nipa, software, purchased, own, rd, artistic,
        government_software, government_rd, software_all, rd_all, other_all, difference =
        Float64.(data.raw[i, 2:end])
    @htl("""
    <div style="max-width:900px;margin:0 auto;font-family:system-ui,sans-serif">
      <style>
        .ipp-rec{border-collapse:collapse;width:100%}.ipp-rec th,.ipp-rec td{padding:.55rem .7rem;border-bottom:1px solid #d8dce2}
        .ipp-rec th{text-align:left}.ipp-rec .num{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}
        .ipp-rec .total{font-weight:750;border-top:2px solid #555}.ipp-rec .same{background:#eef5fc}
      </style>
      <div style="text-align:center;margin-bottom:.65rem">
        <div style="font-size:1.2rem;font-weight:750">The Same IPP Investment in Two Accounting Views</div>
        <div>Benchmark year $(year), current-dollar billions</div>
      </div>
      <table class="ipp-rec">
        <thead><tr><th>View and component</th><th class="num">Value</th></tr></thead>
        <tbody>
          <tr class="same total"><td>I–O matrix: total IPP final demand</td><td class="num">$(ipp_money(total))</td></tr>
          <tr><td style="padding-left:2rem">Private IPP investment</td><td class="num">$(ipp_money(private_io))</td></tr>
          <tr><td style="padding-left:2rem">Government IPP investment</td><td class="num">$(ipp_money(government))</td></tr>
          <tr><td colspan="2" style="height:.4rem;border:0"></td></tr>
          <tr class="same total"><td>Capitalization detail: private IPP investment</td><td class="num">$(ipp_money(private_nipa))</td></tr>
          <tr><td style="padding-left:2rem">Software</td><td class="num">$(ipp_money(software))</td></tr>
          <tr><td style="padding-left:2rem">Research and development</td><td class="num">$(ipp_money(rd))</td></tr>
          <tr><td style="padding-left:2rem">Entertainment, literary, and artistic originals</td><td class="num">$(ipp_money(artistic))</td></tr>
        </tbody>
      </table>
      <div style="margin-top:.7rem;color:#444;font-size:.82rem;line-height:1.4">
        The private total is intentionally repeated: it is the same $(ipp_money(private_io)) in the I–O use table and
        NIPA Table 5.6.5 (difference: $(ipp_money(difference))). Do not add the two blue rows together.
        The government amount completes the I–O total but is not included in NIPA Table 5.6.5.
      </div>
    </div>""")
end

function ipp_component_capitalization_html(year::Integer=2017; path::AbstractString=IPP_CAPITALIZATION_CSV)
    data = ipp_read_capitalization(path)
    i = only(findall(==(year), data.years))
    total, private_io, government, private_nipa, software, purchased, own, rd, artistic,
        government_software, government_rd, software_all, rd_all, other_all, difference =
        Float64.(data.raw[i, 2:end])
    component(label, bought, ownaccount, amount; highlight=false) = @htl("""
      <tr class=$(highlight ? "highlight" : "")><td>$(label)</td>
        <td class="num">$(ipp_display(bought))</td><td class="num">$(ipp_display(ownaccount))</td>
        <td class="num total-value">$(ipp_money(amount))</td></tr>""")
    @htl("""
    <div style="max-width:900px;margin:0 auto;font-family:system-ui,sans-serif">
      <style>
        .ipp-components{border-collapse:collapse;width:100%}.ipp-components th,.ipp-components td{padding:.55rem .7rem;border-bottom:1px solid #d8dce2}
        .ipp-components th{text-align:right}.ipp-components th:first-child{text-align:left}
        .ipp-components .num{text-align:right;font-variant-numeric:tabular-nums}.ipp-components .total-value{font-weight:700}
        .ipp-components .highlight{background:#eef5fc}.ipp-effects{margin-top:1rem;border-collapse:collapse;width:100%}
        .ipp-effects th,.ipp-effects td{padding:.45rem .65rem;border-bottom:1px solid #d8dce2;text-align:right}
        .ipp-effects th:first-child,.ipp-effects td:first-child{text-align:left}.ipp-effects .num{font-variant-numeric:tabular-nums}
      </style>
      <div style="text-align:center;margin-bottom:.65rem">
        <div style="font-size:1.2rem;font-weight:750">Private IPP Capitalization Detail</div>
        <div>Benchmark year $(year), current-dollar billions</div>
      </div>
      <table class="ipp-components">
        <thead><tr><th>IPP asset</th><th>Purchased</th><th>Own account</th><th>Total investment</th></tr></thead>
        <tbody>
          $(component("Software", purchased, own, software; highlight=true))
          $(component("Research and development", missing, missing, rd))
          $(component("Entertainment, literary, and artistic originals", missing, missing, artistic))
          $(component("All private IPP", missing, missing, private_nipa; highlight=true))
        </tbody>
      </table>
      <table class="ipp-effects">
        <thead><tr><th>Observed software remapping</th><th>Intermediate inputs</th><th>Value added</th><th>Gross output</th><th>Final investment</th></tr></thead>
        <tbody>
          <tr><td>Purchased software</td><td class="num">−$(ipp_money(purchased))</td><td class="num">+$(ipp_money(purchased))</td><td class="num">0</td><td class="num">+$(ipp_money(purchased))</td></tr>
          <tr><td>Own-account software</td><td class="num">0</td><td class="num">+$(ipp_money(own))</td><td class="num">+$(ipp_money(own))</td><td class="num">+$(ipp_money(own))</td></tr>
        </tbody>
      </table>
      <div style="margin-top:.7rem;color:#444;font-size:.82rem;line-height:1.4">
        An em dash means Table 5.6.5 reports the asset total but not a purchased/own-account split comparable to software.
        Those totals are shown without assigning an unsupported accounting effect. Source: BEA NIPA Table 5.6.5.
      </div>
    </div>""")
end

function ipp_expanded_remapping_html(year::Integer=2017;
        capitalization_path::AbstractString=IPP_CAPITALIZATION_CSV,
        matrix_path::AbstractString=IPP_MATRIX_CSV)
    cap = ipp_read_capitalization(capitalization_path)
    i = only(findall(==(year), cap.years))
    total, private_io, government, private_nipa, software, purchased, own, rd, artistic,
        government_software, government_rd, software_all, rd_all, other_all, difference =
        Float64.(cap.raw[i, 2:end])
    matrix = ipp_read_matrix(matrix_path)
    selected = matrix.raw[Int.(matrix.raw[:, 1]) .== year, :]
    matrix_ipp_final = sum(Float64.(selected[1:2, 5]))
    isapprox(total, matrix_ipp_final; atol=.002) || error("Capitalization and I–O totals do not reconcile for $(year).")
    remaprow(label, moved, imputed, after; indent=0, strong=false) = @htl("""
      <tr class=$(strong ? "strong" : "")>
        <td style="padding-left:$(.7 + indent * 1.2)rem">$(label)</td>
        <td class="num">0</td><td class="num">$(ipp_display(moved))</td>
        <td class="num">$(ipp_display(imputed))</td><td class="num after">$(ipp_money(after))</td>
      </tr>""")
    @htl("""
    <div style="max-width:1050px;margin:0 auto;font-family:system-ui,sans-serif">
      <style>
        .expanded-remap{border-collapse:collapse;width:100%;font-size:.92rem}
        .expanded-remap th,.expanded-remap td{padding:.55rem .7rem;border-bottom:1px solid #d8dce2}
        .expanded-remap th{text-align:right;vertical-align:bottom}.expanded-remap th:first-child{text-align:left}
        .expanded-remap .num{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}
        .expanded-remap .after{background:#eef5fc;font-weight:700}.expanded-remap .strong{font-weight:750;border-top:2px solid #555}
        .io-match{margin:.9rem auto;padding:.65rem 1rem;max-width:620px;text-align:center;background:#eef5fc;border:1px solid #b9cee3;border-radius:6px;font-weight:700}
        .mini-io{border-collapse:collapse;width:100%;font-size:.9rem}.mini-io th,.mini-io td{padding:.5rem .65rem;border-bottom:1px solid #d8dce2}
        .mini-io th{text-align:right}.mini-io th:first-child{text-align:left}.mini-io .num{text-align:right;font-variant-numeric:tabular-nums}
      </style>
      <div style="text-align:center;margin-bottom:.65rem">
        <div style="font-size:1.2rem;font-weight:750">From IPP Capitalization to the Input–Output Matrix</div>
        <div>Benchmark year $(year), current-dollar billions</div>
      </div>
      <table class="expanded-remap">
        <thead><tr><th>IPP category</th><th>Final investment<br>before capitalization</th>
          <th>Moved from<br>intermediate inputs</th><th>Own-account<br>production added</th>
          <th class="after">Final investment<br>after capitalization</th></tr></thead>
        <tbody>
          $(remaprow("Private IPP", missing, missing, private_nipa; strong=true))
          $(remaprow("Software", purchased, own, software; indent=1))
          $(remaprow("Research and development", missing, missing, rd; indent=1))
          $(remaprow("Other IPP: artistic originals", missing, missing, artistic; indent=1))
          $(remaprow("Government IPP (all categories)", missing, missing, government; strong=true))
          $(remaprow("All IPP", missing, missing, total; strong=true))
        </tbody>
      </table>
      <div class="io-match">After capitalization: $(ipp_money(total)) = I–O matrix IPP final demand: $(ipp_money(matrix_ipp_final))</div>
      <table class="mini-io">
        <thead><tr><th>I–O commodity aggregate</th><th>Used by IPP-producing industries</th>
          <th>Used by other industries</th><th>IPP final demand</th><th>Other final demand</th><th>Total use</th></tr></thead>
        <tbody>
          $([@htl("""<tr><td>$(selected[r,2])</td>$([@htl("<td class='num'>$(ipp_money(Float64(selected[r,c])))</td>") for c in 3:7])</tr>""") for r in 1:2])
        </tbody>
      </table>
      <div style="margin-top:.75rem;color:#444;font-size:.82rem;line-height:1.4">
        Software is the only category for which NIPA Table 5.6.5 provides the purchased and own-account split directly.
        An em dash means the category total is observed but that split is not supplied by this table. Government IPP is
        reported as a single I–O amount here so the after-capitalization column has the same coverage as the I–O matrix.
      </div>
    </div>""")
end

function ipp_full_remapping_table_html(year::Integer=2017;
        capitalization_path::AbstractString=IPP_CAPITALIZATION_CSV,
        matrix_path::AbstractString=IPP_MATRIX_CSV)
    cap = ipp_read_capitalization(capitalization_path)
    i = only(findall(==(year), cap.years))
    total, private_io, government, private_nipa, software, purchased, own, rd, artistic,
        government_software, government_rd, software_all, rd_all, other_all, difference =
        Float64.(cap.raw[i, 2:end])
    matrix = ipp_read_matrix(matrix_path)
    selected = matrix.raw[Int.(matrix.raw[:, 1]) .== year, :]
    labels = string.(selected[:, 2])
    matrix_value(label, column) = Float64(selected[only(findall(==(label), labels)), column])
    intermediate = matrix_value("Intermediate inputs", 7)
    value_added = matrix_value("Value added", 7)
    gross_output = matrix_value("Gross output", 7)
    other_final = sum(Float64.(selected[1:2, 6]))
    current_final = other_final + total
    isapprox(software_all + rd_all + other_all, total; atol=.01) ||
        error("IPP category totals do not reconcile for $(year).")
    tablecell(x) = x isa Number ? ipp_money(x) : x
    function accountrow(label, before, change, after; indent=0, strong=false, shade=false)
        classes = join([strong ? "strong" : "", shade ? "shade" : ""], " ")
        @htl("""<tr class=$(classes)>
          <td style="padding-left:$(.7 + 1.2indent)rem">$(label)</td>
          <td class="num">$(tablecell(before))</td><td class="num change">$(tablecell(change))</td>
          <td class="num current">$(tablecell(after))</td></tr>""")
    end
    @htl("""
    <div style="max-width:980px;margin:0 auto;font-family:system-ui,sans-serif">
      <style>
        .full-remap{border-collapse:collapse;width:100%;font-size:.92rem}
        .full-remap th,.full-remap td{padding:.55rem .7rem;border-bottom:1px solid #d8dce2}
        .full-remap th{text-align:right;vertical-align:bottom}.full-remap th:first-child{text-align:left}
        .full-remap .num{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}
        .full-remap .change{color:#245b91}.full-remap .current{background:#eef5fc}
        .full-remap .strong{font-weight:750;border-top:2px solid #555}.full-remap .shade td:first-child{background:#f7f9fb}
      </style>
      <div style="text-align:center;margin-bottom:.65rem">
        <div style="font-size:1.2rem;font-weight:750">Capitalizing Intellectual Property Products in the U.S. Production Account</div>
        <div>Benchmark year $(year), current-dollar billions</div>
      </div>
      <table class="full-remap">
        <thead><tr><th>Production account</th><th>Before capitalization</th>
          <th>Remapping</th><th class="current">Current treatment</th></tr></thead>
        <tbody>
          $(accountrow("Intermediate inputs", ipp_money(intermediate) * " + purchased IPP", "− purchased IPP", intermediate; strong=true))
          $(accountrow("Value added", value_added - total, "+ " * ipp_money(total), value_added; strong=true))
          $(accountrow("Gross output", ipp_money(gross_output) * " − own-account IPP", "+ own-account IPP", gross_output; strong=true))
          <tr><td colspan="4" style="height:.45rem;border:0"></td></tr>
          $(accountrow("Final demand", other_final, "+ " * ipp_money(total), current_final; strong=true))
          $(accountrow("Software", 0, "+ " * ipp_money(software_all), software_all; indent=1, shade=true))
          $(accountrow("Research and development", 0, "+ " * ipp_money(rd_all), rd_all; indent=1, shade=true))
          $(accountrow("All other IPP", 0, "+ " * ipp_money(other_all), other_all; indent=1, shade=true))
          $(accountrow("All IPP", 0, "+ " * ipp_money(total), total; indent=1, strong=true))
          $(accountrow("All other final demand", other_final, "0", other_final; indent=1))
        </tbody>
      </table>
      <div style="margin-top:.75rem;color:#444;font-size:.82rem;line-height:1.4">
        The current-treatment column uses the same coverage as the benchmark I–O matrix: private plus government IPP.
        Software combines $(ipp_money(software)) private and $(ipp_money(government_software)) government investment;
        R&amp;D combines $(ipp_money(rd)) private and $(ipp_money(government_rd)) government investment; all other IPP is
        entertainment, literary, and artistic originals. The source publishes a purchased/own-account split only for
        private software ($(ipp_money(purchased)) purchased and $(ipp_money(own)) own account), so the first and third
        before-capitalization entries retain the economically correct formulas rather than unsupported numerical splits.
      </div>
    </div>""")
end

function ipp_io_table_html(year::Integer=2024; path::AbstractString=IPP_IO_CSV)
    data = ipp_read_io(path)
    i = findfirst(==(year), data.years)
    isnothing(i) && error("Year $(year) not found in $(path).")
    r = Float64.(data.raw[i, 2:end])
    after_i, after_v, after_go, purchased, own, software, before_i, before_v, before_go = r
    row(label, before, change, after; strong=false) = @htl("""
      <tr style=$(strong ? "font-weight:700;border-top:2px solid #555" : "")>
        <td>$(label)</td><td class="num">$(ipp_money(before))</td>
        <td class="num change">$(change)</td><td class="num">$(ipp_money(after))</td>
      </tr>""")
    @htl("""
    <div style="max-width:900px;margin:0 auto;font-family:system-ui,sans-serif">
      <style>
        .ipp-remap{border-collapse:collapse;width:100%;font-size:.96rem}
        .ipp-remap th,.ipp-remap td{padding:.55rem .7rem;border-bottom:1px solid #d8dce2}
        .ipp-remap th{text-align:right}.ipp-remap th:first-child{text-align:left}
        .ipp-remap .num{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}
        .ipp-remap .change{color:#245b91;font-weight:650}
        .ipp-notes{margin-top:.7rem;color:#444;font-size:.82rem;line-height:1.35}
      </style>
      <div style="text-align:center;margin-bottom:.65rem">
        <div style="font-size:1.2rem;font-weight:750">Capitalizing Software in the U.S. Production Account</div>
        <div>$(year), current-dollar billions</div>
      </div>
      <table class="ipp-remap">
        <thead><tr><th>Production account</th><th>Before capitalization</th><th>Remapping</th><th>Current treatment</th></tr></thead>
        <tbody>
          $(row("Intermediate inputs", before_i, "− " * ipp_money(purchased), after_i))
          $(row("Value added", before_v, "+ " * ipp_money(purchased) * " + " * ipp_money(own), after_v))
          $(row("Gross output", before_go, "+ " * ipp_money(own), after_go; strong=true))
          <tr><td colspan="4" style="height:.45rem;border:0"></td></tr>
          $(row("Software in final investment", 0, "+ " * ipp_money(software), software; strong=true))
        </tbody>
      </table>
      <div class="ipp-notes">
        Purchased software = prepackaged + custom ($(ipp_money(purchased))). Own-account software = $(ipp_money(own)).
        Purchased software is reclassified from intermediate use to final investment; own-account production adds equally
        to output, value added, and investment. Source: BEA Input-Output Table 258 and NIPA Table 5.6.5.
      </div>
    </div>""")
end

