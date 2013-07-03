//Example Code taken from Mike Bostock
// Initial min threshold and max threshold for influence cutoff 
var defMin=.15;
var defMax=1.1;

//Initialize buttons for heatmaps
d3.select("#diffusion_btn").on("click", function() {
    clearTimeout(timeout);
    d3.select("svg").remove();
    $('#diff_inf_options > button').removeClass('active');
    $('#diffusion_btn').addClass('active');
    $('#company_nobel_options').show();
    $('#dataset_options').hide();
    generate_heatmap("nobel",defMin,defMax);
});

d3.select("#influence_btn").on("click", function() {
    clearTimeout(timeout);
    d3.select("svg").remove();
    $('#diff_inf_options > button').removeClass('active');
    $('#influence_btn').addClass('active');
    $('#twitter_btn').addClass('active');
    $('#dataset_options').show();
    $('#company_nobel_options').hide();
    generate_langlang_heatmap("twitter",defMin,defMax);
});

//creates network visualization from scratch
/*
* data = language connections with influence
* langData = number of speakers and other associated data
* langGroups = language group data
* sponsorData = data for memes (dates for when meme reaches each language)
* min = minimum influence for an edge to be included
* max = maximum influence for an edge to be included
*/
function createVisualization(data, langData, langGroups, sponsorData,min,max) {

    //-------------------------------------------------------------
    //variables
    var links=[];
    var w = 1120; //width of svg
    var h = 1000; //height of svg
    var defaultStrokeWidth = "3.5px";       //initial stroke width for nodes
    var expandedStrokeWidth = "16.5px";     //"pop" stroke width for meme animation
    
    //toggles between always displaying arrows and displaying upon selection
    var arrowsAlwaysDisplayed = true;

    //binary threshold for language cutoff
    //This threshold is deprecated
    var threshold=-1;

    //Creating and arranging colors for language families
    var colorScale = d3.scale.ordinal().range(d3.scale.category20().range());
    var colorTemp=[];
    for(var i=0;i<20;i++) {
        colorTemp.push(colorScale(i));
    }

    //random visually pleasing color arrangement 
    var colorArrangement = [0,2,3,1,5,4,10,11,9,7,14,19,16,6,12,13,17,18,8,15];
    var colors=[];
    for(var i=0;i<20;i++) {
        colors.push(colorTemp[colorArrangement[i]]);
    }

    //global boolean variables
    var aNodeIsSelected=false;

    //===================================================================================
    //Useful functions
    //date comparison
    function compare(a,b) {
        if(a.dateString<b.dateString) {
            return -1;
        }
        if(a.dateString>b.dateString) {
            return 1;
        }
        return 0;
    }

    //radius calculation with error handling for when no numSpeakers value is given
    function radius(numSpeakers) {
       var val = Math.pow(numSpeakers,.2)*6;
       if(!val) 
           return 6;
       return val;
    }

    //===================================================================================
    //processing language data, storing full name and number of speakers for each language
    languageData={};
    langData.forEach( function( lang ) {
            languageData[lang.Lang_Code] = {fullname:lang.Lang_Name, numSpeakers:lang.Num_Speakers_M};
    });

    //Code to intialize links

    //commented - ghetto solution for undirected graph, hashing links
    //var linkDict={};
    data.forEach( function( element ) {
    //doesn't include english and links with strength below threshold
    //Threshold checking is deprecated, all nodes are processed, the whole network is filtered later
        if(element.influence>threshold && languageData[element.source] && languageData[element.target]) {
            //var val=element.target+" "+element.source;
            //if(element.source<element.target) {
            //  val=element.source+" "+element.target;
            //}
            //if(!linkDict[val]) {
                links.push({source: element.source , target: element.target , influence: element.influence, selected:"off"});
                //linkDict[val]=true;
            //}
        }
    });


    //Initialize node dictionary
    var nodes = {};


    // Compute the distinct nodes from the links.
    // option = a selector variable for miscellaneous functionality
    // For example: option=1 means that node is selected and should be highlighted
    // default color is black
    links.forEach(function(link) {
        link.source = nodes[link.source] || (nodes[link.source] = {name: link.source, option:0, color:"#000000", numSpeakers: languageData[link.source].numSpeakers});
        link.target = nodes[link.target] || (nodes[link.target] = {name: link.target, option:0, color:"#000000", numSpeakers: languageData[link.target].numSpeakers});
    });


    // Twitter, wiki, books, merged
    // This is a super hacky way to change the dataset on button click
    d3.select("#twitter_btn").on("click", function() {
        d3.select("svg").remove();
        $('#dataset_options > button').removeClass('active');
        $('#twitter_btn').addClass('active');
        generate_network("twitter",min,max);
        //langs = d3.tsv(data_files['twitter']);
        //(langs, langData, langGroups, sponsorData);
    });

    d3.select("#wikipedia_btn").on("click", function() {
        d3.select("svg").remove();
        $('#dataset_options > button').removeClass('active');
        $('#wikipedia_btn').addClass('active');
        generate_network("wikipedia",min,max);
        //langs = d3.tsv(data_files['wikipedia']);
        //createVisualization(langs, langData, langGroups, sponsorData);
    });

    d3.select("#unesco_btn").on("click", function() {
        d3.select("svg").remove();
        $('#dataset_options > button').removeClass('active');
        $('#unesco_btn').addClass('active');
        generate_network("books",min,max);
        //langs = d3.tsv(data_files['books']);
        //createVisualization(langs, langData, langGroups, sponsorData);
    });

    //d3.select("#merged_btn").on("click", function() {
        //d3.select("svg").remove();
        //$('#dataset_options > button').removeClass('active');
        //$('#merged_btn').addClass('active');
        //generate_network("twitter",min,max);
        //langs = d3.tsv(data_files['merged']);
        //createVisualization(langs, langData, langGroups, sponsorData);
    //});


    
    // all of meme data processing code, sorting and storing
    // If no meme is passed in, ignore
    if(meme_name!='none') {
        //computing meme data
        var memeDict={};
        sponsorData.forEach( function( meme ) {
            if(nodes[meme.ISO6393Lang]) {
                if(memeDict[meme.EnglishName]) {
                    var dateArray = meme.FirstDate.split("-");
                    var dateStr=meme.FirstDate;

                    //Corrects the date format to year first, helps with sorting
                    if(dateArray[0].length!=4)
                        dateStr = dateArray[2]+"-"+dateArray[0]+"-"+dateArray[1];


                   memeDict[meme.EnglishName].push({lang: meme.ISO6393Lang, dateString:dateStr,
                        memeNameEng: meme.EnglishName, memeNameInd: meme.IndigName});
                }
                else {
                    memeDict[meme.EnglishName] = [{lang: meme.ISO6393Lang, dateString: meme.FirstDate,
                       memeNameEng: meme.EnglishName, memeNameInd: meme.IndigName}];
                }
            }
        });

        var memeDelayDict = {};//This object encodes delays for languages for a meme

        //The memeDelayDict stores the rank of each meme so that the appropriate transition delay can be assigned
        Object.keys(memeDict).forEach( function( key ) {
            memeDict[key] = memeDict[key].sort(compare);
            memeDelayDict[key]={};
            for(var i=0;i<memeDict[key].length;i++) {
               memeDelayDict[key][memeDict[key][i].lang]=i;
            }
        });
    }



//setup meme menu
//callback function for meme button press
memeAnimation =  function() {
    var memeSelectElement = document.getElementById("memeSelect");
    var memeName = memeSelectElement.options[memeSelectElement.selectedIndex].text;
    unselectMeme();
    selectMeme(memeName);

};

//process language data
    var countGroups=0;
    groupIds = {};
    langToGroup={};

    //assign an ID to each language group that is represented
    // groupIds: language group name -> unique language group id
    langGroups.forEach( function( lang ) {
        langToGroup[lang.Lang_Code] = lang.Viz_Family_Name;
        if((groupIds[lang.Viz_Family_Name]!=0 && !groupIds[lang.Viz_Family_Name]) && nodes[lang.Lang_Code]) {
            groupIds[lang.Viz_Family_Name] = countGroups++;
        }
    });

    //Assigns a group ID to each language, stored in groupDict: languageName -> group id
    groupDict={};
    langGroups.forEach( function( lang ) {
        if(nodes[lang.Lang_Code]) {
            groupDict[lang.Lang_Code]=groupIds[lang.Viz_Family_Name];
        }
    });

    //create node list
    //color nodes in the same family the same color
    //default color for languages not in any family
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

    //create force layout with constants
    var force = d3.layout.force()
        .nodes(nodeList)
        .links(links)
        .size([w, h])
        .linkStrength( function (d) {
            //special constants for english (otherwise the whole network is compresses inwards to english)
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
            //give English a greater charge for more repulsion
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
        .attr("height",h);
//        .attr("width", "100%")
//      .attr("height", "100%")
//        .attr("viewBox", "0 0 800 600");
//      .attr("viewBox","0 0 "+w+" "+h);
    
    //initially invisible while physics engine working
    svg.attr("display","none");

    //ghetto loading message
    var textSVG = d3.select("#network").append("svg:svg")
        .attr("width", w)
        .attr("height", h)
        .attr("id", "textSVG");

    textSVG.append("svg:g").append("svg:text")
        .attr("x", w/2)
        .attr("y", h/2)
        .style("font-size",100)
        .attr("class", "shadow")
        .text("Loading...");

    //deletes loading message and sets network to visible after N milliseconds
    //delayedDisplay(4000);
    delayedDisplay(2000);
    
    //initialize svgs for links, nodes and text
    linksG = svg.append("svg:g").attr("id", "links");
    nodesG = svg.append("svg:g").attr("id", "nodes");
    textG = svg.append("svg:g").attr("id", "text");

    // Per-type markers, as they don't inherit styles.
    svg.append("svg:defs").selectAll("marker")
      .data(["default"])
      .enter().append("svg:marker")
        .attr("id", String)
        .attr("viewBox", "0 -5 10 10")
        .attr("refX", 12)
        .attr("refY", 0)
        .attr("markerWidth", 3)
        .attr("markerHeight", 3)
        .attr("orient", "auto")
        .style("fill", "#aaa")
      .append("svg:path")
        .attr("d", "M0,-5L10,0L0,5");

    //create basic link 
    var linkElem = linksG.selectAll("path").data(force.links(), function(d) {return d.source.name+"-"+d.target.name;});


    //create basic node 
    var nodeElem = nodesG.selectAll("circle").data(force.nodes(), function(d) {return d.name;});


    //create basic text
    var textElem = textG.selectAll("g").data(force.nodes(), function(d) {return d.name;});
   
    //first filtering call
    updateForce(min,max, false);

    //----------------------------------------------------------------------------------------
    //fixes nodes after N*1000 seconds
    //----------------------------------------------------------------------------------------
    delayedFix(3000);
/**
 * takes threshold values and filters/adds nodes and links
 * minThreshold = minimum influence cutoff
 * maxThreshold = maximum influence cutoff
 * fixNodes: boolean = whether or not new nodes should be fixed with very short delay
 */
function updateForce(minThreshold, maxThreshold, fixNodes) {
    var newNodes = {};
    var newLinks = [];
    var newLinkList=[];

    //filter links
    links.forEach( function( link ) {
        if(link.influence>minThreshold && link.influence<maxThreshold) {
            newLinkList.push(link);
        }
    });

    //filter nodes
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

    //add new links
    linkElem = linksG.selectAll("path").data(newLinkList, function(d) {return d.source.name+"-"+d.target.name;});

    //add paths to links with markers
    path = linkElem
    .enter()
    .append("svg:path")
    //================================================================================
    //Function that controls link stroke width
    //================================================================================
    .style("stroke-width", function(d) { return Math.log(d.influence*60)})
    .attr("class","link default")
    //.on("mouseover", selectLink)
    //.on("mouseout", unselectLink)
    .attr("marker-end", function(d) { return "url(#default)";});

    //add tool tips to links with influence values
    path
    .append("svg:title")
    .text( function(d) {
        return "Influence: " + parseFloat(d.influence).toFixed(5);
    });

    //remove filtered links
    linkElem.exit().remove();

    //new nodes
    nodeElem = nodesG.selectAll("circle")
    .data(newNodeList, function(d) { return d.name;});

    //add circles for new nodes
    circle =nodeElem
      .enter().append("svg:circle")
      

    //set appropriate radii and settings, add tool tip with number of speakers
    circle
    .attr("r", function(d) { 
        return radius(d.numSpeakers);
    })
    .style("stroke", function(d) {return d.color})
    .style("fill", function(d) {return d.color})
    .on("mouseover",selectNode)
    .on("mouseout", unselectAll)
    .call(force.drag)
    .append("svg:title")
        .text(function(d) {
            return "Language Family: "+langToGroup[d.name]+"\n"+"Number of Speakers (Millions): "+languageData[d.name].numSpeakers;
    });

    //remove filtered nodes
    nodeElem.exit().remove();
    textElem = textG.selectAll("g")
        .data(newNodeList, function(d) {return d.name;});

    //add new text (labels)
    text = textElem.enter().append("svg:g");

    // Here we write the node labels.
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

    //remove filtered labels
    textElem.exit().remove();

    //fix nodes quickly if desired
    if(fixNodes) {
        delayedFix(1000);
    }

    //start network again
    force.start();
}

/**
 *  Colors by meme date
 *
 */

function selectMemeGradient(meme) {
    var meme_gradient = d3.scale.linear()
        .domain([0,1])
        .range(["blue","red"]);
    var setupDelay = 6000;       //time before animation starts
    if(data_src=='wikipedia')
        setupDelay = 8000;
    var animationTiming = 700;  //how long the animation for each node takes (ms)
    var delayBetween = 1000;    //delay between consecutive languages receiving memes
    var afterSetupDelay = 1000;

    nodeElem.transition()
    .style("fill", function(d) {
        return meme_gradient(memeDelayDict[meme][d.name]/memeDict[meme].length);
    })
    .duration(200)
    .delay(setupDelay);
   
}

/**
 * Starts meme animation with given meme
 */
function selectMeme(meme) {
    var setupDelay = 6000;       //time before animation starts
    if(data_src=='wikipedia')
        setupDelay = 8000;
    var animationTiming = 700;  //how long the animation for each node takes (ms)
    var delayBetween = 1000;    //delay between consecutive languages receiving memes
    var afterSetupDelay = 1000;

    //causes all cirlce edges to pulse, indicating start of meme diffusion
    nodeElem.transition()
    .style("stroke-width", expandedStrokeWidth)
    .duration(200)
    .delay(setupDelay)
    .each("end", function() {
        d3.select(this).transition().style("stroke-width", defaultStrokeWidth)
    });

    //pulse all the nodes in order of meme diffusion
    nodeElem.transition()
    .style("stroke-width", function(d) {
            if(memeDelayDict[meme][d.name]>=0)
            return expandedStrokeWidth;
        return defaultStrokeWidth;
    })
    .delay( function(d, i) { return setupDelay + afterSetupDelay + memeDelayDict[meme][d.name]*(delayBetween+1);})
    .duration(200)
    .each("end", function() {
        d3.select(this).transition().style("stroke-width",defaultStrokeWidth)
        .each("end", function() {
            d3.select(this).transition().style("fill", function(d) {
                if(memeDelayDict[meme][d.name]>=0)
                        return d.color;
                    return "#fff";
                })
                .duration(animationTiming);
            });
    });
}

//reset all nodes
function unselectMeme() {
    nodeElem.transition()
    .style("fill", "#fff")
    .duration(100)
    .each("end", function() {
        d3.select(this).transition().style("stroke-width",defaultStrokeWidth);
    });
}

//selects the node that the mouse is over
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

//unselects all nodes
function unselectAll() {

    aNodeIsSelected=false;

    for(var i=0;i<nodeList.length;i++) {
        nodeList[i].option=0;
    }
    links.forEach( function(link) { link.selected="off";});
    //force.resume();

}

//selects link and sets it to outgoing
function selectLink() {
    this.__data__.selected="outgoing";
    //force.resume();
}

//unselect link
function unselectLink() {
    links.forEach( function(link) {link.selected="off";});
    //force.resume();
}

//fixes all nodes after a given delay using a transition
function delayedFix(delayInMillis) {
    nodeElem.transition()
        .delay(delayInMillis)
        .attr("fixed","true")
        .each("end", function() {
            nodes[this.__data__.name].fixed=true;
        });
}

//displays network after a given delay
function delayedDisplay(delayInMillis) {
    svg.transition()
        .delay(delayInMillis)
        .each("end", function() {
            svg.attr("display", "inline");
            svg.attr("margin", "auto");
            textSVG.attr("display","none");
            d3.select('#textSVG').remove();
        });
}
// Use elliptical arc path segments to doubly-encode directionality.
function tick() {

    var darkFactor = .4;
    var lightFactor = .4;
    linkElem.attr("d", function(d) {
        var dx = d.target.x - d.source.x,
            dy = d.target.y - d.source.y,
        dr = Math.sqrt(dx * dx + dy * dy);
        
        var sourceRadius = radius(d.source.numSpeakers);
        var targetRadius = radius(d.target.numSpeakers);
        var dxu = dx/dr;
        var dyu = dy/dr;
        var dXoffsetSource = d.source.x + dxu*sourceRadius;
        var dYoffsetSource = d.source.y + dyu*sourceRadius;
        var dXoffsetTarget = d.target.x - dxu*targetRadius;
        var dYoffsetTarget = d.target.y - dyu*targetRadius;
        dr*=3;
//        return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
        return "M" + dXoffsetSource + "," + dYoffsetSource + "A" + dr + "," + dr + " 0 0,1 " + dXoffsetTarget + "," + dYoffsetTarget;
    })
    .style("stroke", function(d) {
        if(d.selected=="outgoing") {
            return "orange";
        }
        if(d.selected=="incoming") {
            return "black";
        }
        return "#B3B3BA"; // "#ddd" #92929D
    })
    .style("fill", "none") // remove that black shadow!
    .attr("marker-end", function(d) { 
        if(d.selected!="off" || arrowsAlwaysDisplayed)
            return "url(#default)";
        return null;
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
        var val = radius(d.numSpeakers);
        if(d.option==0)
            return val;
        return val + 50/val;
    
    })
    

        textElem.attr("transform", function(d) {
            return "translate(" + d.x + "," + d.y + ")";
        });
}
    // Slider
    $('#slider').slider({
        range: true,
        values: [min*100.0, max*100.0],     //These values specify the default in range [0,100]
        slide: function( event, ui ) {
            var min_inf = $("#slider").slider("values", 0)/100;
            var max_inf = $("#slider").slider("values", 1)/100;

            updateForce(min_inf,max_inf, true);
        }
    });

    updateForce(min,max, false);
    if(meme_name!='none') {
//        selectMeme(meme_name);
        selectMemeGradient(meme_name);
    }
    //selectMeme(meme_name);
}

// Influence files to load for each different source
var data_files = {"twitter": "/static/data/lang_connections/twitter_langlang.tsv",
"wikipedia": "/static/data/lang_connections/wikipedia_langlang.tsv",
"books": "/static/data/lang_connections/books_langlang.tsv"}
//"merged": "/static/data/lang_connections/merged_langlang.tsv"}

var meme_files = {"sponsors": "/static/data/diffusion/sponsors_data_2012-10-19.tsv",
"nobel": "/static/data/diffusion/laureates_final_2012-10-19.tsv"}

function generate_network(p_data_src,min,max) {
    d3.tsv(data_files[p_data_src], function(langs) {
        d3.tsv("/static/data/lang_connections/speakers_iso639-3_full.tsv", function( data ) {
            d3.tsv("/static/data/lang_connections/speakers_iso639-3_20_families.tsv", function( langGroups) {
                d3.tsv(meme_files[meme_src], function( sponsorData) {
                    createVisualization(langs,data,langGroups, sponsorData,min,max);
                });
            });
        });
    });
};

generate_network("twitter",defMin,defMax)

d3.select("#twitter_btn").on("load", function() {
        d3.select("svg").remove();
        $('#dataset_options > button').removeClass('active');
        $('#twitter_btn').addClass('active');
    });