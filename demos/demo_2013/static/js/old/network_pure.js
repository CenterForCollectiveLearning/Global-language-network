


//Example Code taken from Mike Bostock

function createVisualization(data, langData, langGroups) {

	//-------------------------------------------------------------
	//variables
	var links=[];
	var w = 1120; //width of svg
    var h = 1000; //height of svg
    var defaultStrokeWidth = "3.5px";
    var expandedStrokeWidth = "16.5px";



	//binary threshold for language cutoff
	var threshold=-1;
    var colorScale = d3.scale.ordinal().range(d3.scale.category20().range());
    var colorTemp=[];
    for(var i=0;i<20;i++) {
        colorTemp.push(colorScale(i));
    }
    var colorArrangement = [0,2,3,1,5,4,10,11,9,7,14,19,16,6,12,13,17,18,8,15];
    var colors=[];
    for(var i=0;i<20;i++) {
        colors.push(colorTemp[colorArrangement[i]]);
    }

    //global boolean variables
    var aNodeIsSelected=false;

    function compare(a,b) {
        if(a.dateString<b.dateString) {
            return -1;
        }   
        if(a.dateString>b.dateString) {
            return 1;
        }
        return 0;
    }
	languageData={};
	langData.forEach( function( lang ) {
			languageData[lang.Lang_Code] = {fullname:lang.Lang_Name, numSpeakers:lang.Num_Speakers_M};
	});

    //ghetto solution, hashing links
	//var linkDict={};
	data.forEach( function( element ) {
	//doesn't include english and links with strength below threshold
		if(element.influence>threshold && languageData[element.source] && languageData[element.target]) {
			//var val=element.target+" "+element.source;
			//if(element.source<element.target) {
			//	val=element.source+" "+element.target;
			//}
			//if(!linkDict[val]) {
				links.push({source: element.source , target: element.target , influence: element.influence, selected:"off"});
				//linkDict[val]=true;
			//}
		}
	});
	var nodes = {};


	// Compute the distinct nodes from the links.
	links.forEach(function(link) {
		link.source = nodes[link.source] || (nodes[link.source] = {name: link.source, option:0, color:"#000000"});
		link.target = nodes[link.target] || (nodes[link.target] = {name: link.target, option:0, color:"#000000"});
	});

	//process language data
	var countGroups=0;
	groupIds = {};
	langToGroup={};
	langGroups.forEach( function( lang ) {
		langToGroup[lang.Lang_Code] = lang.Viz_Family_Name;
		if((groupIds[lang.Viz_Family_Name]!=0 && !groupIds[lang.Viz_Family_Name]) && nodes[lang.Lang_Code]) {
			groupIds[lang.Viz_Family_Name] = countGroups++;
		}
	});
	groupDict={};
	langGroups.forEach( function( lang ) {
		if(nodes[lang.Lang_Code]) {
			groupDict[lang.Lang_Code]=groupIds[lang.Viz_Family_Name];
		}
	});

//create node list
	nodeList = d3.values(nodes)
	nodeList.forEach(function( node ) {
		if(!colors[groupDict[node.name]]) {
			nodes[node.name].color="#d3d3d3";
		}
		else {
			nodes[node.name].color=colors[groupDict[node.name]];
		}
	});
	//manual positioning for clustering
	for(var i=0;i<nodeList.length;i++) {
		if(nodeList[i].name=="eng") {
			nodeList[i].fixed = true;
			nodeList[i].x=700;
			nodeList[i].y=450;
		}
		if(nodeList[i].name=="zho") {
			nodeList[i].x=250;
			nodeList[i].y=250;
			nodeList[i].fixed = true;
		}
		if(nodeList[i].name=="spa") {
			nodeList[i].x=1000;
			nodeList[i].y=750;
			nodeList[i].fixed = true;
		}
		if(nodeList[i].name=="rus") {
			nodeList[i].x=1000;
			nodeList[i].y=250;
			nodeList[i].fixed = true;
		}
		if(nodeList[i].name=="deu") {
			nodeList[i].x=300;
			nodeList[i].y=700;
			nodeList[i].fixed = true;
		}
		if(nodeList[i].name=="ara") {
			nodeList[i].x=300;
			nodeList[i].y=500;
			nodeList[i].fixed = true;
		}
	}

    //create force layout
	var force = d3.layout.force()
		.nodes(nodeList)
		.links(links)
		.size([w, h])
		.linkStrength( function (d) {
			if(d.source.name=="eng" || d.target.name=="eng") {
				return 0.03;
			}
			if(groupDict[d.source.name]==groupDict[d.target.name]) {
				return Math.pow(d.influence,.4);
			}
			return Math.pow(d.influence,.7);
		})
		.gravity(.25)
		.charge( function(d,ind) {
			if(d.name=="eng") {
				return -1200;
			}
			return -1000;
		})
		//.charge(-800)
		.on("tick", tick)
		.start();

	//===========================================================================================
	//creating svg element
	var svg = d3.select("#network").append("svg:svg")
		.attr("width", w)
		.attr("height", h);

    linksG = svg.append("svg:g").attr("id", "links");
    nodesG = svg.append("svg:g").attr("id", "nodes");
    textG = svg.append("svg:g").attr("id", "text");
	// Per-type markers, as they don't inherit styles.
	svg.append("svg:defs").selectAll("marker")
	  .data(["suit", "licensing", "resolved"])
	  .enter().append("svg:marker")
		.attr("id", String)
		.attr("viewBox", "0 -5 10 10")
		.attr("refX", 15)
		.attr("refY", -1.5)
		.attr("markerWidth", 0)
		.attr("markerHeight", 0)
		.attr("orient", "auto")
	  .append("svg:path")
		.attr("d", "M0,-5L10,0L0,5");

    var linkElem = linksG.selectAll("path").data(force.links(), function(d) {return d.source.name+"-"+d.target.name;});

	var path= linkElem.enter().append("svg:path")
	.style("stroke-width", function(d) { return Math.log(d.influence*170)})
    .attr("class","link default")
    .on("mouseover", selectLink)
    .on("mouseout", unselectLink);

    path.append("svg:title")
    .text( function(d) {
        return "Influence: " + parseFloat(d.influence).toFixed(5);
    });
		//.attr("marker-end", "url(#defaultMarker)");

    var nodeElem = nodesG.selectAll("circle").data(force.nodes(), function(d) {return d.name;});

	var circle = nodeElem
	  .enter().append("svg:circle")
		.attr("r", function(d) {  return Math.pow(languageData[d.name].numSpeakers,.2)*6;})
    .style("stroke", function(d) {return d.color})
    .on("mouseover",selectNode)
    .on("mouseout", unselectAll)
		.call(force.drag);

	circle.append("svg:title")
		.text(function(d) {
			return "Language Group: "+langToGroup[d.name]+"\n"+"Number of Speakers (Millions): "+languageData[d.name].numSpeakers;
    });

    var textElem = textG.selectAll("g").data(force.nodes(), function(d) {return d.name;});

	var text = textElem
		.enter().append("svg:g");

	// A copy of the text with a thick white stroke for legibility.
	text.append("svg:text")
		.attr("x", 8)
		.attr("y", ".31em")
		.attr("class", "shadow")
		.text(function(d) { return languageData[d.name].fullname; });

	text.append("svg:text")
		.attr("x", 8)
		.attr("y", ".31em")
		.text(function(d) { return languageData[d.name].fullname; });


	function updateForce(minThreshold, maxThreshold) {
		var newNodes = {};
		var newLinkList=[];
		
		links.forEach( function( link ) {
			if(link.influence>minThreshold && link.influence<maxThreshold) {
				newLinkList.push(link);
			}
		});
		
		newLinkList.forEach(function(link) {
			newNodes[link.source.name]=true;
			newNodes[link.target.name]=true;
		});
		
		var newNodeList=[];
		nodeList.forEach( function( node ) {
			if(newNodes[node.name]) {
				newNodeList.push(node);
			}
		});
		force.nodes(newNodeList);
		force.links(newLinkList);
		
		linkElem = linksG.selectAll("path").data(newLinkList, function(d) {return d.source.name+"-"+d.target.name;});
		
		path = linkElem
		.enter()
		.append("svg:path")
		.style("stroke-width", function(d) { return Math.log(d.influence*170)})
		.attr("class","link default")
		.on("mouseover", selectLink)
		.on("mouseout", unselectLink)
		
		path
		.append("svg:title")
		.text( function(d) {
			return "Influence: " + parseFloat(d.influence).toFixed(5);
		});

		linkElem.exit().remove();
	   
		nodeElem = nodesG.selectAll("circle")
		.data(newNodeList, function(d) { return d.name;});

		circle =nodeElem
		  .enter().append("svg:circle");
	   
		circle
		.attr("r", function(d) {  return Math.pow(languageData[d.name].numSpeakers,.2)*6;})
		.style("stroke", function(d) {return d.color})
		.on("mouseover",selectNode)
		.on("mouseout", unselectAll)
		.call(force.drag)
		.append("svg:title")
			.text(function(d) {
				return "Language Group: "+langToGroup[d.name]+"\n"+"Number of Speakers (Millions): "+languageData[d.name].numSpeakers;
		});
		
		nodeElem.exit().remove();
		textElem = textG.selectAll("g")
			.data(newNodeList, function(d) {return d.name;});

		text = textElem.enter().append("svg:g");

		// A copy of the text with a thick white stroke for legibility.
		text.append("svg:text")
			.attr("x", 8)
			.attr("y", ".31em")
			.attr("class", "shadow")
			.text(function(d) { return languageData[d.name].fullname; });

		text.append("svg:text")
			.attr("x", 8)
			.attr("y", ".31em")
			.text(function(d) { return languageData[d.name].fullname; });

		textElem.exit().remove();
	//    force.on("tick",tick); 
		force.start();
	}

	function selectNode() {

		aNodeIsSelected=true;

			var point = d3.svg.mouse(this);
			var miniInd=-1;
			for(var i=0;i<nodeList.length;i++) {
				nodeList[i].option=0;
				if(nodeList[i].name==this.__data__.name) {
					miniInd=i;
				}
			}
			nodeList[miniInd].option=1;
			links.forEach( function( link ) {
				link.selected="off";
			if(link.source == nodeList[miniInd]) {
				link.selected="outgoing";
			}
				if(link.target == nodeList[miniInd]) {
				link.selected="incoming";
			}
			});
			//restarts animation timer
			//force.resume();
	}

	function unselectAll() {

		aNodeIsSelected=false;

		for(var i=0;i<nodeList.length;i++) {
			nodeList[i].option=0;
		}
		links.forEach( function(link) { link.selected="off";});
		//force.resume();

	}

	function selectLink() {
		this.__data__.selected="outgoing";
		//force.resume();
	}

	function unselectLink() {
		links.forEach( function(link) {link.selected="off";});
		//force.resume();
	}
	// Use elliptical arc path segments to doubly-encode directionality.
	function tick() {

		var darkFactor = .4;
		var lightFactor = .4;
			linkElem.attr("d", function(d) {
				var dx = d.target.x - d.source.x,
					dy = d.target.y - d.source.y,
				dr = Math.sqrt(dx * dx + dy * dy);

				dr*=5;
			return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
			})
			.style("stroke", function(d) {
				if(d.selected=="outgoing") {
					return "orange";
				}
				if(d.selected=="incoming") {
					return "black";
				}
				return "#ddd";
		});


			nodeElem.attr("transform", function(d) {
				return "translate(" + d.x + "," + d.y + ")";
		})
		.style("stroke", function(d) {
			if(d.option==0) {
				return d.color;
			}
			//return d.color;
			return "black";
		})
		.attr("r", function(d) {
			var val =  Math.pow(languageData[d.name].numSpeakers,.2)*6;
			if(d.option==0)
				return val;
			return val + 50/val;

		})

//=======================================================================================
//Unnecessary but good looking effect, might be too slow
        .transition()
        .style("fill", function(d) {
            if(d.option==0) {
                return "#fff";
            }
            return d.color;
        })
        .delay(0)
        .duration(175);



			textElem.attr("transform", function(d) {
				return "translate(" + d.x + "," + d.y + ")";
			});
	}


	//Default threshold call, not necessary
    updateForce(.015,1.1);
}

// Influence files to load for each different source
var data_files = {"twitter": "/static/data/lang_connections/twitter_langlang.tsv",
"wikipedia": "/static/data/lang_connections/wikipedia_langlang.tsv",
"books": "/static/data/lang_connections/books_langlang.tsv",
"merged": "/static/data/lang_connections/merged_langlang.tsv"}

d3.tsv(data_files[data_src], function(langs) {
	d3.tsv("/static/data/lang_connections/speakers_iso639-3_full.tsv", function( data ) {
       	d3.tsv("/static/data/lang_connections/speakers_iso639-3_20_families.tsv", function( langGroups) {
                    	createVisualization(langs,data,langGroups);
		});
	});
});
