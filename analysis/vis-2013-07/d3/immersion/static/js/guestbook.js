var VMail;
(function (VMail) {
    (function (Guestbook) {
        var FRICTION = 0.9;
        var LINKDISTANCE = 20;
        var CHARGE = -1000;
        var GRAVITY = 0.9;
        var WIDTH = $(window).width();
        var HEIGHT = $(window).height() - 100; // was 200
        Guestbook.viz = null;
        function toTitleCase(str) {
            return str.replace(/\w\S*/g, function (txt) {
                return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
            });
        }
        var induceNetwork = function (data) {
            var nodes = [];
            var idToNode = {
            };
            for(var contactid in data) {
                var node = {
                    attr: {"size": data[contactid], },// undefined,
                    links: [],
                    id: contactid,
                    skip: false
                };
                node.attr = {
                    contact: data[contactid],
                    size: 300
                };
                idToNode[contactid] = node;
                nodes.push(node);
            }
            var idpairToLink = {
            };
            for(var a in data) {
                var ll = data[a]['links'];
                // Get the lngth of the ll dictionary
                //for(var i = 0; i < Object.keys(ll).length; i++) {
                for(var i = 0; i < ll.length; i++) {
                    var b = ll[i]['target_lang'];
                    if(!(b in idToNode) || a === b) {
                        continue;
                    }
                    var src = a;
                    var trg = b;
                    /*if(a > b) {
                        var src = b;
                        var trg = a;
                    }*/
                    var key = src + '#' + trg;
                    if(!(key in idpairToLink)) {
                        var link = {
                            source: idToNode[src],
                            target: idToNode[trg],
                            attr: {
                                weight: ll[i]['target_exposure'],
                                color: 0,
                            },
                            skip: false
                        };
                        idToNode[src].links.push(link);
                        idToNode[trg].links.push(link);
                        idpairToLink[key] = link;
                    }
                }
            }
            var links = [];
            for(var idpair in idpairToLink) {
                links.push(idpairToLink[idpair]);
            }
            return {
                nodes: nodes,
                links: links
            };
        };
        var showNetwork = function (data) {
            // VISUALIZATION SETTINGS
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
                    live: true
                },
                nodeLabelFunc: function (attr) {
                    return toTitleCase(attr.contact.full_name);
                },
                nodeSizeFunc: function (attr) {
                    return attr.contact.nspeakers / 100;
                    // return 25;
                },
                nodeColorFunc: function (attr) {
                    return attr.contact.family;
                },
                linkSizeFunc: function (attr) {
                    return attr.weight * 100;
                    // return 12;
                },
                linkColorFunc: function (attr) {
                    return '#A00000';
                },
                clickHandler: function (node) {
                    return;
                }
            };
            if(VMail.Guestbook.viz === null) {
                VMail.Guestbook.viz = new VMail.Viz.NetworkViz(settings, false); // Do not use guestbook
            }
            var graph = induceNetwork(data);
            VMail.Guestbook.viz.updateNetwork(graph);
        };
        window.onload = function () {
            var getGuestbook = function () {
                $.getJSON('/data/gln_test2.json', function (data) { // was /getguestbook
                    if(data === undefined) {
                        console.log("ERROR: guestbook data should never be undefined.");
                        return;
                    }
                    console.log(data);
                    console.log("Showing network data");
                    showNetwork(data);
                });
            };
            getGuestbook();
            var ws = new WebSocket('ws://' + window.document.location.host + '/websocket');
            ws.onopen = function () {
                console.log("socket opened");
            };
            ws.onmessage = function (evt) {
                getGuestbook();
            };
        };
    })(VMail.Guestbook || (VMail.Guestbook = {}));
    var Guestbook = VMail.Guestbook;
})(VMail || (VMail = {}));
