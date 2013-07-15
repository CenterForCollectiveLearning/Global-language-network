var VMail;
(function (VMail) {
    (function (DB) {
        var InMemoryDB = (function () {
            function InMemoryDB(emails, contacts) {
                this.start = 0;
                this.end = emails.length;
                this.emails = emails;
                this.contacts = contacts;
                this.contactDetails = this.getContactDetails();
            }
            InMemoryDB.prototype.getTopContacts = function (topN, start, end, ascending) {
                var contactDetails = this.getContactDetails(start, end);
                var p = -3;
                var getScores = function (a) {
                    if(contactDetails[a.id] === undefined) {
                        return null;
                    }
                    return [
                        Math.pow((Math.pow(contactDetails[a.id].nRcvEmails, p) + Math.pow(contactDetails[a.id].nSentEmails, p)) / 2.0, 1.0 / p)
                    ];
                };
                return this.getRanking(topN, getScores, ascending);
            };
            InMemoryDB.prototype.getNumberOfContacts = function () {
                var ncontacts = 0;
                for(var cid in this.contacts) {
                    var contact = this.contacts[cid];
                    if(Math.min(contact["rcv"], contact["sent"]) >= 3) {
                        ncontacts += 1;
                    }
                }
                return ncontacts;
            };
            InMemoryDB.prototype.getContactDetails = function (start, end) {
                var contactDetails = [];
                if(start === undefined) {
                    start = new Date(this.emails[0].timestamp * 1000);
                }
                if(end === undefined) {
                    end = new Date(this.emails[this.emails.length - 1].timestamp * 1000);
                }
                var startt = +start;
                var endt = +end;
                for(var i = this.start; i < this.end; i++) {
                    var ev = this.emails[i];
                    var time = this.emails[i].timestamp * 1000;
                    if(time < startt || time > endt) {
                        continue;
                    }
                    var isSent = !(ev.hasOwnProperty('source'));
                    if(!isSent && this.isContact(ev.source)) {
                        var a = ev.source.toString();
                        if(contactDetails[a] === undefined) {
                            contactDetails[a] = {
                                id: a,
                                nRcvEmails: 0,
                                nSentEmails: 0,
                                nRcvEmailsPvt: 0,
                                nSentEmailsPvt: 0,
                                nSentEmailsNorm: 0,
                                nRcvEmailsNorm: 0,
                                firstEmail: new Date(ev.timestamp * 1000),
                                lastEmail: undefined
                            };
                        }
                        contactDetails[a].nRcvEmails += 1;
                        contactDetails[a].nRcvEmailsNorm += 1.0 / (ev.destinations.length + 1);
                        contactDetails[a].lastEmail = new Date(ev.timestamp * 1000);
                        if(ev.destinations.length === 0) {
                            contactDetails[a].nRcvEmailsPvt += 1;
                        }
                    }
                    for(var j = 0; j < ev.destinations.length; j++) {
                        var b = ev.destinations[j].toString();
                        if(!this.isContact(b)) {
                            continue;
                        }
                        if(contactDetails[b] === undefined) {
                            contactDetails[b] = {
                                id: b,
                                nRcvEmails: 0,
                                nSentEmails: 0,
                                nRcvEmailsPvt: 0,
                                nSentEmailsPvt: 0,
                                nSentEmailsNorm: 0,
                                nRcvEmailsNorm: 0,
                                firstEmail: new Date(ev.timestamp * 1000),
                                lastEmail: undefined
                            };
                        }
                        if(isSent) {
                            contactDetails[b].lastEmail = new Date(ev.timestamp * 1000);
                            contactDetails[b].nSentEmails += 1;
                            contactDetails[b].nSentEmailsNorm += 1.0 / ev.destinations.length;
                        }
                    }
                    if(isSent && this.isContact(b) && ev.destinations.length === 1) {
                        b = ev.destinations[0].toString();
                        contactDetails[b].nSentEmailsPvt += 1;
                    }
                }
                return contactDetails;
            };
            InMemoryDB.prototype.getEmailDatesSent = function () {
                var dates = [];
                for(var i = this.start; i < this.end; i++) {
                    var ev = this.emails[i];
                    var isSent = !(ev.hasOwnProperty('source'));
                    if(isSent) {
                        dates.push({
                            date: new Date(ev.timestamp * 1000),
                            weight: 1.0
                        });
                    }
                }
                return dates;
            };
            InMemoryDB.prototype.getEmailDatesRcv = function () {
                var dates = [];
                for(var i = this.start; i < this.end; i++) {
                    var ev = this.emails[i];
                    var isSent = !(ev.hasOwnProperty('source'));
                    if(!isSent) {
                        dates.push({
                            date: new Date(ev.timestamp * 1000),
                            weight: 1.0
                        });
                    }
                }
                return dates;
            };
            InMemoryDB.prototype.getEmailDatesByContact = function (contact) {
                var dates = [];
                for(var i = this.start; i < this.end; i++) {
                    var ev = this.emails[i];
                    var isSent = !(ev.hasOwnProperty('source'));
                    if(isSent) {
                        for(var j = 0; j < ev.destinations.length; j++) {
                            if(ev.destinations[j].toString() === contact.id) {
                                var weight = 1.0;
                                dates.push({
                                    date: new Date(ev.timestamp * 1000),
                                    weight: weight
                                });
                            }
                        }
                    } else if(ev.source.toString() === contact.id) {
                        var weight = 1.0;
                        dates.push({
                            date: new Date(ev.timestamp * 1000),
                            weight: weight
                        });
                    }
                }
                return dates;
            };
            InMemoryDB.prototype.buildIntroductionTrees = function () {
                var nodes = [];
                for(var i = this.start; i < this.end; i++) {
                    var ev = this.emails[i];
                    var isRcv = (ev.hasOwnProperty('source'));
                    if(isRcv) {
                        var a = ev.source.toString();
                        if(!this.isContact(a)) {
                            continue;
                        }
                        var score = Math.min(this.contactDetails[a].nRcvEmails, this.contactDetails[a].nSentEmails);
                        if(score < 1) {
                            continue;
                        }
                        if(nodes[a] === undefined) {
                            nodes[a] = {
                                contact: this.contacts[a]
                            };
                        }
                    }
                    for(var j = 0; j < ev.destinations.length; j++) {
                        var b = ev.destinations[j].toString();
                        if(!this.isContact(b)) {
                            continue;
                        }
                        var score = Math.min(this.contactDetails[b].nRcvEmails, this.contactDetails[b].nSentEmails);
                        if(score < 1) {
                            continue;
                        }
                        if(nodes[b] === undefined) {
                            nodes[b] = {
                                contact: this.contacts[b]
                            };
                            if(isRcv) {
                                if(nodes[a].children === undefined) {
                                    nodes[a].children = [];
                                }
                                nodes[a].children.push(nodes[b]);
                                nodes[b].father = nodes[a];
                            }
                        }
                    }
                }
                return nodes;
            };
            InMemoryDB.prototype.isContact = function (id) {
                if(isNaN(id)) {
                    return false;
                }
                return true;
            };
            InMemoryDB.prototype.getTimestampsFromContact = function (contact) {
                var res = [];
                for(var i = this.start; i < this.end; i++) {
                    var ev = this.emails[i];
                    var isRcv = (ev.hasOwnProperty('source'));
                    if(isRcv) {
                        var a = ev.source.toString();
                        if(a === contact.id) {
                            res.push(ev.timestamp);
                        }
                    } else {
                        for(var j = 0; j < ev.destinations.length; j++) {
                            var b = ev.destinations[j].toString();
                            if(b === contact.id) {
                                res.push(ev.timestamp);
                                break;
                            }
                        }
                    }
                }
                return res;
            };
            InMemoryDB.prototype.getNormCommunicationVariance = function (contact) {
                console.log(contact.name + "-------------------------------------");
                var times = this.getTimestampsFromContact(contact);
                for(var i = 0; i < times.length; i++) {
                    times[i] /= 1000000;
                }
                for(var k = 1; k < 100; k++) {
                    var assignment = new Array(times.length);
                    var centroid = new Array(k);
                    for(var j = 0; j < k; j++) {
                        var randint = Math.floor(Math.random() * times.length);
                        centroid[j] = times[randint];
                    }
                    var npoints = new Array(k);
                    for(var iter = 0; iter < 100; iter++) {
                        var centroid2 = new Array(k);
                        for(var j = 0; j < k; j++) {
                            centroid2[j] = 0;
                            npoints[j] = 0;
                        }
                        for(var i = 0; i < times.length; i++) {
                            var minDist = 2000000000;
                            var minIdx = -1;
                            for(var j = 0; j < k; j++) {
                                var dist = Math.abs(times[i] - centroid[j]);
                                if(dist < minDist) {
                                    minDist = dist;
                                    minIdx = j;
                                }
                            }
                            assignment[i] = minIdx;
                            centroid2[minIdx] += times[i];
                            npoints[minIdx] += 1;
                        }
                        for(var j = 0; j < k; j++) {
                            if(npoints[j] === 0) {
                                var randint = Math.floor(Math.random() * times.length);
                                centroid[j] = times[randint];
                            } else {
                                centroid[j] = centroid2[j] / npoints[j];
                            }
                        }
                    }
                    var clusterVariance = new Array(k);
                    for(var j = 0; j < k; j++) {
                        clusterVariance[j] = 0;
                    }
                    for(var i = 0; i < times.length; i++) {
                        clusterVariance[assignment[i]] += Math.pow(times[i] - centroid[assignment[i]], 2);
                    }
                    for(var j = 0; j < k; j++) {
                        clusterVariance[j] /= npoints[j];
                    }
                    var wcv = 0;
                    for(var j = 0; j < k; j++) {
                        wcv += clusterVariance[j];
                    }
                    var mean = 0;
                    for(var j = 0; j < k; j++) {
                        mean += centroid[j];
                    }
                    mean /= k;
                    var bcv = 0;
                    for(var j = 0; j < k; j++) {
                        bcv += Math.pow(centroid[j] - mean, 2);
                    }
                    bcv /= k;
                    console.log(k + " : " + (Math.sqrt(bcv) + Math.sqrt(wcv)));
                }
                return 0;
            };
            InMemoryDB.prototype.getCommunicationVariance = function (contact) {
                var times = this.getTimestampsFromContact(contact);
                var mean = 0;
                for(var i = 0; i < times.length; i++) {
                    mean += (times[i] / 1000000) / times.length;
                }
                var variance = 0;
                for(var i = 0; i < times.length; i++) {
                    variance += Math.pow(times[i] / 1000000 - mean, 2) / times.length;
                }
                return Math.sqrt(variance);
            };
            InMemoryDB.prototype.getTimestampsNewContacts = function () {
                var seen = [];
                var dates = [];
                for(var i = this.start; i < this.end; i++) {
                    var ev = this.emails[i];
                    var isRcv = (ev.hasOwnProperty('source'));
                    if(isRcv && this.isContact(ev.source)) {
                        if(seen[ev.source] === undefined) {
                            dates.push({
                                date: new Date(ev.timestamp * 1000),
                                weight: 1.0
                            });
                            seen[ev.source] = true;
                        }
                    }
                    if(!isRcv) {
                        for(var j = 0; j < ev.destinations.length; j++) {
                            var b = ev.destinations[j];
                            if(this.isContact(b)) {
                                if(seen[b] === undefined) {
                                    dates.push({
                                        date: new Date(ev.timestamp * 1000),
                                        weight: 1.0
                                    });
                                    seen[b] = true;
                                }
                            }
                        }
                    }
                }
                return dates;
            };
            InMemoryDB.prototype.getIntroductions = function (contact) {
                var father = [];
                var seen = [];
                var children = [];
                for(var i = this.start; i < this.end; i++) {
                    var ev = this.emails[i];
                    var isRcv = (ev.hasOwnProperty('source'));
                    if(isRcv) {
                        var a = ev.source.toString();
                        if(!this.isContact(a)) {
                            continue;
                        }
                        seen[a] = true;
                    }
                    for(var j = 0; j < ev.destinations.length; j++) {
                        var b = ev.destinations[j].toString();
                        if(!this.isContact(b)) {
                            continue;
                        }
                        if(seen[b] === undefined && isRcv) {
                            father[b] = this.contacts[ev.source.toString()];
                        }
                        if(isRcv && ev.source.toString() === contact.id) {
                            if(seen[b] === undefined) {
                                var score = Math.min(this.contactDetails[b].nRcvEmails, this.contactDetails[b].nSentEmails);
                                if(score >= 1) {
                                    children.push(this.contacts[b]);
                                }
                            }
                        }
                        seen[b] = true;
                    }
                }
                var id = contact.id;
                var fathers = [];
                while(father[id] !== undefined) {
                    fathers.push(father[id]);
                    id = father[id];
                }
                return {
                    children: children,
                    fathers: fathers
                };
            };
            InMemoryDB.prototype.getRanking = function (topN, getScores, ascending) {
                var results = [];
                for(var id in this.contacts) {
                    var contact = this.contacts[id];
                    var scores = getScores(contact);
                    if(scores === null) {
                        continue;
                    }
                    results.push({
                        contact: contact,
                        scores: scores
                    });
                }
                var comp = function (a, b) {
                    for(var i = 0; i < a.scores.length; i++) {
                        if(a.scores[i] !== b.scores[i]) {
                            return b.scores[i] - a.scores[i];
                        }
                    }
                    return 0;
                };
                results.sort(comp);
                if(ascending) {
                    results.reverse();
                }
                return results.slice(0, topN);
            };
            return InMemoryDB;
        })();
        DB.InMemoryDB = InMemoryDB;        
        function setupDB(json) {
            var emails = json.events;
            for(var i = 0; i < emails.length; i++) {
                var email = emails[i];
                if(email.f !== undefined) {
                    email.source = email.f;
                    delete email.f;
                }
                email.destinations = email.d;
                delete email.d;
                email.timestamp = email.t;
                delete email.t;
            }
            var contacts = json.contacts;
            for(var id in contacts) {
                var contact = contacts[id];
                contact.name = contact.n;
                delete contact.n;
                contact.aliases = contact.e;
                delete contact.e;
                contact.id = id;
            }
            return new InMemoryDB(emails, contacts);
        }
        DB.setupDB = setupDB;
    })(VMail.DB || (VMail.DB = {}));
    var DB = VMail.DB;
})(VMail || (VMail = {}));
