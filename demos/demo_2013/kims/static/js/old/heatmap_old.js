/*
 * Heat map helper functions
 */

$('#vis_options > button').removeClass('active');

// Convert a date in yyyy-mm-dd format into number of days
function process_date(input) {
    var parts = input.match(/(\d+)/g);
    // new Date(year, month [, date [, hours[, minutes[, seconds[, ms]]]]])
    year = parseInt(parts[0], 10);
    month = parseInt(parts[1], 10);
    days = parseInt(parts[2], 10);
    days_total = (year * 365) + (month * 30) + days
    return days_total;
}

var margin = {top: 85, right: 0, bottom: 5, left: 225}, /* 80 0 10 80 */
    width = 870,
    height = 870;

var x = d3.scale.ordinal().rangeBands([0, width]),
    y = d3.scale.ordinal().rangeBands([0, height]),
    z = d3.scale.linear().domain([0, 4]).clamp(true),
    c = d3.scale.category10().domain(d3.range(10));

var fill = d3.scale.linear()
    .domain([0, 0.2, 0.4, 0.6, 0.8, 1])
    .range(["blue", "green", "yellow", "orange", "red"]);


var datasets = {company: "/static/data/diffusion/sponsors_data_2012-10-19.tsv",
		nobel: "/static/data/diffusion/laureates_final_2012-10-19.tsv",
		twitter: "/static/data/lang_connections/twitter_langlang.tsv",
		wikipedia: "/static/data/lang_connections/wikipedia_langlang.tsv",
		unesco: "/static/data/lang_connections/books_langlang.tsv",
		merged: "/static/data/lang_connections/merged_langlang.tsv"};

lang_data = {};
lang_data_full = {};
d3.tsv("/static/data/lang_connections/speakers_iso639-3_full.tsv", function(data) {
    data.forEach(function(lang) {
	full_name = lang.Lang_Name;
	full_name = full_name.replace(" (macrolanguage)", "");
	full_name = full_name.replace("Greek (Modern)", "Greek");
	full_name = full_name.replace("macrolanguage", "");
	full_name = full_name.replace("(ca. 450-1100)", "");
	full_name = full_name.replace("(post 1500)", "");
	properties_dict = {full_name: full_name, numSpeakers: parseFloat(lang.Num_Speakers_M), lang_code: lang.Lang_Code};
	try {
	    properties_dict.blurb = lang.Blurb;
	} catch (e) {
	} finally {
	    lang_data_full[full_name] = properties_dict;
	    lang_data[lang.Lang_Code] = properties_dict;
	}
    });
});

pagerank_data = {};
d3.tsv("/static/data/rev_dir_pagerank_rankings.tsv", function(data) {
    data.forEach(function(lang) {
	pagerank_data[lang.lang_code] = {pagerank: parseFloat(lang.pagerank)};
    });
});

function get_wiki_url(lang_code, meme) {
    return lang_code + '.wikipedia.org/wiki/' + meme
}

function generate_heatmap(dataset_name) {
    dataset = datasets[dataset_name];

    cur_width = width;
    cur_height = height;
    if (dataset_name != 'twitter') {
	cur_width = 1200;
	cur_height = 1200;
    }

    var svg = d3.select("#heatmap").append("svg")
	.attr("width", cur_width + margin.left + margin.right)
	.attr("height", cur_height + margin.top + margin.bottom)
	.style("margin-left", - margin.left + "px")
	.append("g")
	.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    d3.tsv(dataset, function(input) {
	var matrix = [],  // matrix mapping languages to companies
	indig_names = {},
	wiki_lang_codes = {},
	languages = [],  // list of languages (str)
	companies = [],  // list of companies (str)
	links = [];  // list of {language, company, date}

	company_counts = {};
	language_counts = {};
	company_reach = {};
	company_influence = {};
	min_date = Number.MAX_VALUE;
	max_date = Number.MIN_VALUE;

	input.forEach(function(ele) {
	    lang = lang_data[ele.ISO6393Lang]["full_name"];
	    company = ele.EnglishName;
	    num_speakers = ele.Num_Speakers_M;
	    date = process_date(ele.FirstDate);

	    if (languages.indexOf(lang) == -1) {
		languages.push(lang);
	    }
	    if (companies.indexOf(company) == -1) {
		companies.push(company);
	    }
	    if (date < min_date) {
		min_date = date;
	    }
	    if (date > max_date) {
		max_date = date;
	    }
	    properties_dict = {"language": lang, "company": company, "date": date, "language_code": ele.ISO6393Lang, "indig_name": ele.IndigName};

	    if (dataset_name == "nobel") {
		anno_date = process_date(ele.Anno_Date);
		properties_dict.anno_date = anno_date;
	    }
	    if (!(company in indig_names)) {
		indig_names[company] = {};
	    }
	    if (!(company in wiki_lang_codes)) {
		wiki_lang_codes[company] = {};
	    }
	    wiki_lang_codes[company][lang] = ele.Lang;
	    indig_names[company][lang] = ele.IndigName;
	    links.push(properties_dict);
	});


	// Sort the languages alphabetically  TODO: Make this pipe through to the end;
	languages = languages.sort();

	var language_count = languages.length,
	company_count = companies.length;

	// Compute index per language and company.
	companies.forEach(function(company, i) {
	    company.index = i;
	    company_counts[i] = 0;
	    company_reach[i] = 0;
	    company_influence[i] = 0;
	    matrix[i] = d3.range(language_count).map(function(j) {return {x: j, y: i, z: 0}; });
	});

	// Populate language_count dictionary to count languages
	languages.forEach(function(lang, i) {
	    lang.index = i;
	    language_counts[i] = 0;
	});

	// Convert links to matrix.
	links.forEach(function(link) {
	    lang_code = link["language_code"];
	    company_index = companies.indexOf(link["company"]);
	    language_index = languages.indexOf(link["language"]);

	    if (dataset_name == "company") {
		date = (link["date"] - min_date) / (max_date - min_date);
	    } else if (dataset_name == "nobel") {
		date = (link["date"] - link["anno_date"]);
	    }

	    matrix[company_index][language_index].z += date;

	    company_counts[company_index] += 1;
	    language_counts[language_index] += 1;
	    company_reach[company_index] += lang_data[lang_code].numSpeakers;

	    if (lang_code in pagerank_data) {
		company_influence[company_index] += pagerank_data[lang_code].pagerank;
	    }
	});

	// Precompute the orders.
	var company_orders = {
	    name: d3.range(company_count).sort(function(a, b) { return d3.ascending(companies[a], companies[b]); }),
	    count: d3.range(company_count).sort(function(a, b) { return d3.ascending(company_counts[b], company_counts[a]); }),
	    reach: d3.range(company_count).sort(function(a, b) { return d3.ascending(company_reach[b], company_reach[a]); }),
	    influence: d3.range(company_count).sort(function(a, b) { return d3.ascending(company_influence[b], company_influence[a]); })
	};

	// The default sort order.
	x.domain(company_orders.name);

	svg.append("rect")
	    .attr("class", "background")
	    .attr("width", width)
	    .attr("height", height);

	// Rows
	var row = svg.selectAll(".row")
	    .data(matrix)
	    .enter().append("g")
	    .attr("class", "row")
	    .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
	    .each(row);

	row.append("line")
	    .attr("x2", width);

	row.append("text")
	    .attr("x", -6)
	    .attr("y", x.rangeBand() / 2)
	    .attr("dy", ".32em")
	    .attr("text-anchor", "end")
	    .text(function(d, i) { return companies[i]; })

	// Properties
	var column = svg.selectAll(".column")
	    .data(matrix)
	    .enter().append("g")
	    .attr("class", "column")
	    .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });

	column.append("line")
	    .attr("x1", -width);

	column.append("text")
	    .attr("x", 6)
	    .attr("y", x.rangeBand() / 2)
	    .attr("dy", ".32em")
	    .attr("text-anchor", "start")
	    .text(function(d, i) { return languages[i]; })

	// Cells
	function row(row) {
	    var cell = d3.select(this).selectAll(".cell")
		.data(row.filter(function(d) { return d.z; }))
		.enter().append("rect")
		.attr("class", "cell")
		.attr("x", function(d) { return x(d.x); })
		.attr("width", x.rangeBand())
		.attr("height", x.rangeBand())
		.style("fill", function(d) { return fill(d.z); })
		.on("mouseover", mouseover)
		.on("mouseout", mouseout)
		.on("click", cell_click);
	}

	function cell_click(p) {
	    language_index = p.x;
	    company_index = p.y;
	    company = companies[company_index];
	    language = languages[language_index];
	    wiki_lang_code = wiki_lang_codes[company][language];
	    lang_code = lang_data_full[language].lang_code;
	    indig_name = indig_names[company][language];

	    var wiki_url = get_wiki_url(wiki_lang_code, indig_name)
	    window.open('http://www.' + wiki_url, '_parent');
	}

	/* Note that p returns an object with x, y (relevant indices), and z as attributes */
	function mouseover(p) {
	    language_index = p.x;
	    company_index = p.y;
	    company = companies[company_index];
	    language = languages[language_index];

	    wiki_lang_code = wiki_lang_codes[company][language];
	    indig_name = indig_names[company][language];

	    d3.selectAll(".row text").classed("active", function(d, i) { return i == p.y; });
	    d3.selectAll(".column text").classed("active", function(d, i) { return i == p.x; });
	    $("#bottom_navbar").show();
	    $("#bottom_navbar h1").text(function() {return company + " in " + language + ": "});
	    var wiki_url = get_wiki_url(wiki_lang_code, indig_name)
	    var wiki_link = "<a href='" + wiki_url + "'>" + wiki_url + "</a>";
	    $("#bottom_navbar h1").append(wiki_url);
	}

	function mouseout() {
	    d3.selectAll("text").classed("active", false);
	    $('#bottom_navbar').hide();
	    $("#bottom_navbar h1").text('');
	}

	//// Button Presses ////
	// Diffusion and Influence
	d3.select("#diffusion_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#diff_inf_options > button').removeClass('active');
	    $('#diffusion_btn').addClass('active');
	    $('#company_nobel_options').show();
	    $('#dataset_options').hide();
	    generate_heatmap("nobel");
	});

	d3.select("#influence_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#diff_inf_options > button').removeClass('active');
	    $('#influence_btn').addClass('active');
	    $('#merged_btn').addClass('active');
	    $('#dataset_options').show();
	    $('#company_nobel_options').hide();
	    generate_langlang_heatmap("merged");
	});

	// Company and Nobel
	d3.select("#company_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#company_nobel_options > button').removeClass('active');
	    $('#company_btn').addClass('active');
	    generate_heatmap(this.value);
	});

	d3.select("#nobel_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#company_nobel_options > button').removeClass('active');
	    $('#nobel_btn').addClass('active');
	    generate_heatmap(this.value);
	});

	// Sort
	d3.select("#name_btn").on("click", function() {
	    clearTimeout(timeout);
	    $('#row_options > button').removeClass('active');
	    $(this).addClass('active');
	    company_order(this.value);
	});

	d3.select("#count_btn").on("click", function() {
	    clearTimeout(timeout);
	    $('#row_options > button').removeClass('active');
	    $(this).addClass('active');
	    company_order(this.value);
	});

	d3.select("#reach_btn").on("click", function() {
	    clearTimeout(timeout);
	    $('#row_options > button').removeClass('active');
	    $(this).addClass('active');
	    company_order(this.value);
	});

	d3.select("#inf_btn").on("click", function() {
	    clearTimeout(timeout);
	    $('#row_options > button').removeClass('active');
	    $(this).addClass('active');
	    company_order(this.value);
	});

	function company_order(value) {
	    x.domain(company_orders[value]);

	    var t = svg.transition().duration(500);

	    t.selectAll(".row")
		.delay(function(d, i) { return x(i) * 1; })
		.attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
		.selectAll(".cell")
		.delay(function(d) { return x(d.x) * 2; })
		.attr("x", function(d) { return x(d.x); });

	    t.selectAll(".column")
	    	.delay(function(d, i) { return x(i) * 1; })
	    	.attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });
	}

	var timeout = setTimeout(function() {
	    // company_order("count");
	    // $('#row_options > button').removeClass('active');
	    // $('#count_btn').addClass('active');
	}, 5000);
    });
}


function generate_langlang_heatmap(dataset_name) {
    dataset = datasets[dataset_name];

    var svg = d3.select("#heatmap").append("svg")
	.attr("width", width + margin.left + margin.right)
	.attr("height", height + margin.top + margin.bottom)
	.style("margin-left", - margin.left + "px")
	.append("g")
	.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    d3.tsv(dataset, function(input) {
	var matrix = [],
	languages = [];
	links = [];
	languages_counts = {};
	languages_reach = {};
	languages_influence = {};
	min_value = Number.MAX_VALUE;
	max_value = Number.MIN_VALUE;

	input.forEach(function(ele) {
	    source_code = ele.source;
	    target_code = ele.target;

	    if (source_code in lang_data && target_code in lang_data) {
		source_full = lang_data[source_code]["full_name"];
		target_full = lang_data[target_code]["full_name"];

		if (dataset_name == "unesco" && 20 > parseFloat(ele.common)) {
		} else {
		    influence = -1 * Math.log(parseFloat(ele.influence));
		    common = parseInt(ele.common);

		    if (languages.indexOf(source_full) == -1) {
			languages.push(source_full);
		    }
		    if (languages.indexOf(target_full) == -1) {
			languages.push(target_full);
		    }
		    if (influence < min_value) {
			min_value = influence;
		    }
		    if (influence > max_value) {
			max_value = influence;
		    }
		    properties_dict = {"source_code": source_code, "target_code": target_code,
				       "source": source_full, "target": target_full,
				       "target": lang_data[target_code]["full_name"], "influence": influence};
		    links.push(properties_dict);
		}
	    }
	});

	var langlang_fill = d3.scale.linear()
	    .domain([min_value, (1.5 * min_value + 0.5 * max_value) / 2, (min_value + max_value) / 2, (0.5 * min_value + 1.5 * max_value) / 2, max_value])
	    .range(["blue", "green", "yellow", "orange", "red"]);

	var language_count = languages.length;

	// Compute index per node.
	languages.forEach(function(lang, i) {
	    lang.index = i;
	    languages_counts[i] = 0;
	    languages_reach[i] = 0;
	    languages_influence[i] = 0;
	    matrix[i] = d3.range(language_count).map(function(j) { return {x: j, y: i, z: 0}; });
	});

	// Convert links to matrix; count character occurrences.
	links.forEach(function(link) {
	    s_language_index = languages.indexOf(link.source);
	    t_language_index = languages.indexOf(link.target);
	    matrix[s_language_index][t_language_index].z += link.influence;
	    languages_counts[s_language_index] += 1;
	    languages_reach[s_language_index] += lang_data[link.target_code].numSpeakers;
	    if (link.source_code in pagerank_data) {
		languages_influence[s_language_index] += pagerank_data[link.source_code].pagerank;
	    }
	});

	// Precompute the orders.
	var orders = {
	    name: d3.range(language_count).sort(function(a, b) { return d3.ascending(languages[a], languages[b]); }),
	    count: d3.range(language_count).sort(function(a, b) { return languages_counts[b] - languages_counts[a]; }),
	    reach: d3.range(language_count).sort(function(a, b) { return languages_reach[b] - languages_reach[a]; }),
	    influence: d3.range(language_count).sort(function(a, b) { return languages_influence[b] - languages_influence[a]; })
	};

	// The default sort order.
	x.domain(orders.name);

	svg.append("rect")
	    .attr("class", "background")
	    .attr("width", width)
	    .attr("height", height);

	var row = svg.selectAll(".row")
	    .data(matrix)
	    .enter().append("g")
	    .attr("class", "row")
	    .attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
	    .each(row);

	row.append("line")
	    .attr("x2", width);

	row.append("text")
	    .attr("x", -6)
	    .attr("y", x.rangeBand() / 2)
	    .attr("dy", ".32em")
	    .attr("text-anchor", "end")
	    .text(function(d, i) { return languages[i]; });

	var column = svg.selectAll(".column")
	    .data(matrix)
	    .enter().append("g")
	    .attr("class", "column")
	    .attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });

	column.append("line")
	    .attr("x1", -width);

	column.append("text")
	    .attr("x", 6)
	    .attr("y", x.rangeBand() / 2)
	    .attr("dy", ".32em")
	    .attr("text-anchor", "start")
	    .text(function(d, i) { return languages[i]; });

	function row(row) {
	    var cell = d3.select(this).selectAll(".cell")
		.data(row.filter(function(d) { return d.z; }))
		.enter().append("rect")
		.attr("class", "cell")
		.attr("x", function(d) { return x(d.x); })
		.attr("width", x.rangeBand())
		.attr("height", x.rangeBand())
		.style("fill", function(d) { return langlang_fill(d.z); })
		.on("mouseover", mouseover)
		.on("mouseout", mouseout);
	}

	function mouseover(p) {
	    language_x_index = p.y;
	    language_y_index = p.x;
	    language_x = languages[language_x_index];
	    language_y = languages[language_y_index];
	    d3.selectAll(".row text").classed("active", function(d, i) { return i == p.y; });
	    d3.selectAll(".column text").classed("active", function(d, i) { return i == p.x; });
	    $("#bottom_navbar").show();
	    var x = '.';
	    if ('blurb' in lang_data_full[language_y]) {
		x += " " + lang_data_full[language_y]["blurb"];
	    }
	    if ('blurb' in lang_data_full[language_x]) {
		x += " " + lang_data_full[language_x]["blurb"];
	    }
	    $("#bottom_navbar h1").text(function() {return language_x + ", " + language_y + x});
	}

	function mouseout() {
	    d3.selectAll("text").classed("active", false);
	    $('#bottom_navbar').hide();
	    $("#bottom_navbar h1").text('');
	}

	function order(value) {
	    x.domain(orders[value]);

	    var t = svg.transition().duration(500);

	    t.selectAll(".row")
		.delay(function(d, i) { return x(i) * 1; })
		.attr("transform", function(d, i) { return "translate(0," + x(i) + ")"; })
		.selectAll(".cell")
		.delay(function(d) { return x(d.x) * 2; })
		.attr("x", function(d) { return x(d.x); });

	    t.selectAll(".column")
		.delay(function(d, i) { return x(i) * 1; })
		.attr("transform", function(d, i) { return "translate(" + x(i) + ")rotate(-90)"; });
	}

	// Diffusion and Influence
	d3.select("#diffusion_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#diff_inf_options > button').removeClass('active');
	    $('#diffusion_btn').addClass('active');
	    $('#company_nobel_options').show();
	    $('#dataset_options').hide();
	    generate_heatmap("nobel");
	});

	d3.select("#influence_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#diff_inf_options > button').removeClass('active');
	    $('#influence_btn').addClass('active');
	    $('#dataset_options').show();
	    $('#company_nobel_options').hide();
	    generate_heatmap("merged");
	});

	// Twitter, wiki, books, merged
	d3.select("#twitter_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#dataset_options > button').removeClass('active');
	    $(this).addClass('active');
	    generate_langlang_heatmap(this.value);
	});

	d3.select("#wikipedia_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#dataset_options > button').removeClass('active');
	    $(this).addClass('active');
	    generate_langlang_heatmap(this.value);
	});

	d3.select("#unesco_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#dataset_options > button').removeClass('active');
	    $(this).addClass('active');
	    generate_langlang_heatmap(this.value);
	});

	d3.select("#merged_btn").on("click", function() {
	    clearTimeout(timeout);
	    d3.select("svg").remove();
	    $('#dataset_options > button').removeClass('active');
	    $(this).addClass('active');
	    generate_langlang_heatmap(this.value);
	});


	// Sort
	d3.select("#name_btn").on("click", function() {
	    clearTimeout(timeout);
	    $('#row_options > button').removeClass('active');
	    $(this).addClass('active');
	    order(this.value);
	});

	d3.select("#count_btn").on("click", function() {
	    clearTimeout(timeout);
	    $('#row_options > button').removeClass('active');
	    $(this).addClass('active');
	    order(this.value);
	});

	d3.select("#reach_btn").on("click", function() {
	    clearTimeout(timeout);
	    $('#row_options > button').removeClass('active');
	    $(this).addClass('active');
	    order(this.value);
	});

	d3.select("#inf_btn").on("click", function() {
	    clearTimeout(timeout);
	    $('#row_options > button').removeClass('active');
	    $(this).addClass('active');
	    order(this.value);
	});

	var timeout = setTimeout(function() {
	    order("count");
	    $('#row_options > button').removeClass('active');
	    $('#count_btn').addClass('active');
	}, 5000);
    });
}

generate_heatmap("company");
