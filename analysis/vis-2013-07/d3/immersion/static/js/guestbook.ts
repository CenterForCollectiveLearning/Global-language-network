// /// <reference path="d3types.ts" />
/// <reference path="jquery.d.ts" />


//Presentation Layout module
module VMail.Guestbook {

// ********** CONSTANTS **********
var FRICTION = 0.9;
var LINKDISTANCE = 20;
var CHARGE = -1000;
var GRAVITY = 0.9;
var WIDTH = $(window).width();
var HEIGHT = $(window).height() - 200;
//***********************************

export var viz: VMail.Viz.NetworkViz = null;

//querying the server every 300ms in the background to see if new version
// is available or to refresh the loading information


function toTitleCase(str)
{
    return str.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
}

var induceNetwork = (data:any) : VMail.Graph.IGraph => {
  // map from id to node
  var nodes: VMail.Graph.INode[] = [];
  var idToNode: { [id: string]: VMail.Graph.INode; } = {};
  for (var contactid in data) {
    var node = { attr: undefined, links: [], id: contactid, skip: false };
    node.attr = {
      contact: data[contactid],
      size : 300
    };
    idToNode[contactid] = node;
    nodes.push(node);
  }
  //don't allow duplicate links by making the idPair as min(src,trg) --> max(src, trg)
  var idpairToLink: { [idpair: string]: VMail.Graph.ILink; } = {};
  for (var a in data) {
    var ll: string[] = data[a]['links'];
    for(var i=0; i < ll.length; i++) {
      var b = ll[i];
      if (! (b in idToNode) || a===b) continue;
      var src = a;
      var trg = b;
      if (a > b) {
        var src = b;
        var trg = a;
      }
      var key = src + '#' + trg;
      if (!(key in idpairToLink)) {
        var link = {source: idToNode[src], target: idToNode[trg], attr: {weight: 0}, skip: false};
        idToNode[src].links.push(link);
        idToNode[trg].links.push(link);
        idpairToLink[key] = link;
      }
    }
  }
  var links: VMail.Graph.ILink[] = [];
  for (var idpair in idpairToLink) {
    links.push(idpairToLink[idpair]);
  }
  //links.sort((a,b) => {return b.attr.weight - a.attr.weight});
  return {nodes: nodes, links:links};
}

var showNetwork = (data) => {
  var settings = {
      svgHolder: "#network",
      size: {
        width: WIDTH,
        height: HEIGHT
      },
      forceParameters: {
        friction: FRICTION,
        gravity: GRAVITY,
        linkDistance: LINKDISTANCE,
        charge: -1500,
        live:true
      },
      nodeLabelFunc: (attr : any) : string => {
        return toTitleCase(attr.contact.userinfo.name);
      },
      nodeSizeFunc: (attr) => {return 25;},
      linkSizeFunc: (attr) => {return 2;},
      colorFunc: (attr) => {return '#A00000';},
      clickHandler: (node: VMail.Graph.INode) => {return;}
    };

    //vizualize the network
    if(VMail.Guestbook.viz === null) { VMail.Guestbook.viz = new VMail.Viz.NetworkViz(settings, true); }
    var graph = induceNetwork(data);
    //updateNetwork(true);
    VMail.Guestbook.viz.updateNetwork(graph);
}


window.onload = () => {
  var getGuestbook = () => {
    $.getJSON('/getguestbook', (data) => {
      if (data === undefined) {
        console.log("ERROR: guestbook data should never be undefined.");
        return
      }
      console.log(data);
      console.log("Showing network data")
      showNetwork(data);
    });
  };
  getGuestbook();
  var ws = new WebSocket('ws://' + window.document.location.host + '/websocket');
  ws.onopen = function() { console.log("socket opened") };
  ws.onmessage = function (evt) { getGuestbook(); };

}
}