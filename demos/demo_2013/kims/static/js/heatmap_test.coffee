###
Heatmap Helper Functions
###

$('#vis_options > button').removeClass('active')

process_date = (input) ->
        parts = input.match(/(d+)/g)
        year = parseInt(parts[0], 10)
        month = parseInt(parts[1], 10)
        days = parseInt(parts[2], 10)
        return (year * 365) + (month * 30) + days

get_wiki_url = (lang_code, meme) ->
        return lang_code + '.wikipedia.org/wiki/' + meme

margin = { top: 85, right: 0, bottom: 5, left: 250 }
width = 1200
height = 1200

x = d3.scale.ordinal().rangeBands([0, width])
y = d3.scale.ordinal().rangeBands([0, width])

datasets = {
        company: "/static/data/diffusion/sponsors_data_2012-10-19.tsv",
        nobel: "/static/data/diffusion/laureates_final_2012-10-19.tsv",
        twitter: "/static/data/lang_connections/twitter_langlang.tsv",
        wikipedia: "/static/data/lang_connections/wikipedia_langlang.tsv",
        unesco: "/static/data/lang_connections/books_langlang.tsv",
        merged: "/static/data/lang_connections/merged_langlang.tsv",
        speakers: "/static/data/lang_connections/speakers_iso639-3_full.tsv" }

generate_heatmap = (dataset_name) ->
        dataset = datasets[dataset_name]
        svg = d3.select("#heatmap").append("svg")
                .attr("width", width + margin.left + margin.right)
