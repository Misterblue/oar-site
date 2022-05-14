// Copyright 2018 Robert Adams
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Create OAR file display page

const VERSION = '2.0.3';

const conversionTypes = [
    'unoptimized',
    'smallassets',
    'mergedmaterials'
];

const tableColumns = [
    'OAR file',
    'Desc']
    .concat(conversionTypes);

let baseURL = 'https://files.misterblue.com/BasilTest/convoar/';
// let viewURL = 'https://misterblue.com/justview/justview.html';
let viewURL = 'https://herbal3d.org/basil/JustView.html';

// When document is ready, read the table defining 'index.json' and build the table.
window.onload = function() {
    LogMessage('Version ' + VERSION);

    DebugLog('Fetching ' + baseURL + 'index.json');
    fetch(baseURL + 'index.json')
    .then( response => {
        if (response.ok) {
            return response.json();
        }
        throw new Error(response.status);
    })
    .then( data => {
        BuildTable(data)
    })
    .catch( () => {
        BuildErrorTable(response.status);
    });
};

// Place a message in a scrolling debug area. Not for general user communication.
function LogMessage(pMsg, pClass) {
    const debugNode = document.getElementById('DEBUGG');
    if (debugNode) {
        const newLine = document.createElement('div');
        newLine.appendChild(document.createTextNode(pMsg));
        if (pClass) {
            newLine.setAttribute('class', pClass);
        };
        debugNode.appendChild(newLine);
        while (debugNode.childElementCount > 20) {
            debugNode.removeChild(debugNode.firstChild);
        };
    }
    else {
        console.log('DEBUGG:' + msg);
    }
};

function DebugLog(msg) {
    LogMessage(msg);
};

function ErrorLog(msg) {
    LogMesssage(msg, 'c-errorMsg');
};

// Build the OAR display table.
// Input data is:
// {
// OARBaseName: {
//     "oar": "OARFileName",
//     "image": "optionalImageFilename",
//     "desc": "optionalDescriptionTXTorHTMLFilename",
//     "types": {
//         "unoptimized": {
//             "gltf": "GLTFFilename",
//             "zip": "optionalZIPFilename",
//             "tgz": "optionalTGZFilename"
//         },
//         "smallassets": {
//             "gltf": "GLTFFilename",
//             "zip": "optionalZIPFilename",
//             "tgz": "optionalTGZFilename"
//         },
//         "mergedmaterials": {
//             "gltf": "GLTFFilename",
//             "zip": "optionalZIPFilename",
//             "tgz": "optionalTGZFilename"
//         }
//     }
// },
// AnotherOARBaseName: {
//     ...
// },
// ...
// }
function BuildTable(data) {
    let rows = [];

    // Create row of headers
    let headers = [];
    tableColumns.forEach(col => {
        headers.push(makeHeader(col));
    });
    rows.push(makeRow(headers));

    // For each OAR file, create row of description and converted forms
    Object.keys(data).forEach( oar => {
        const entry = data[oar];

        // Columns being created for this entry
        let cols = [];

        // First column created in 'firstData' 
        let firstData = [];
        firstData.push(makeDiv(oar, 'c-oarName'));
        if (entry.oar) {
            firstData.push(makeLink(baseURL + oar + '/' + entry.oar, makeButtonSmall('OAR')));
        }
        if (entry.image) {
            firstData.push(makeImage(baseURL + oar + '/' + entry.image, 'c-oarImage'));
        }
        cols.push(makeData(firstData, 'c-col-name'));

        // Create second column with description info
        if (entry.desc) {
            if (entry.desc.endsWith('.html')) {
                // If the description is an html file, we put a div that will
                //    be filled when the fetch of the contents is complete.
                let descTag = oar + '-desc';
                let descDiv = makeDiv();
                descDiv.setAttribute('id', descTag);
                cols.push(makeData(descDiv, 'c-col-desc'));

                const descURL = baseURL + oar + '/' + entry.desc;
                fetch(descURL)
                .then(response => {
                    if (response.ok) {
                        return response.text();
                    }
                    throw new Error(response.status);
                })
                .then( descText => {
                    descDiv.innerHTML = descText;
                })
                .catch(e => {
                    descDiv.append(makeText(`Failure fetching ${entry.desc}: ${e}`));
                });
            }
            else {
                // The description is just a text string
                cols.push(makeData(makeText(entry.desc, 'c-col-desc')));
            }
        }
        else {
            cols.push(makeData(makeText('.', 'c-col-desc')));
        }

        // Following columns are for the different conversions of the OAR
        conversionTypes.forEach( conv => {
            if (entry.types[conv]) {
                cols.push(makeDataSelection(entry.types[conv], conv, oar));
            }
            else {
                cols.push(makeData('.'));
            }
        });

        // Entry columns complete. Push into 'rows'
        rows.push(makeRow(cols));
    });
    document.getElementById('c-tableplace').replaceChildren(makeTable(rows, 'c-table'));
};

function BuildErrorTable(e) {
    document.getElementById('c-tableplace').replaceChildren(makeText('Could not load OAR index file'));
};

// Return a table data element containing everything about this type version of the oar
function makeDataSelection(typeDesc, type, oar) {
    /*
    <td class="c-col-selection">
        <div class="c-selection">
            <div class="c-viewer">
                <a href="view" target="_blank">
                    <button type="button">View</button>
                </a>
            </div>
            <div class="c-downloads">
                <div>Download:</div>
                <a href="toTGZ">
                    <button type="button">TGZ</button>
                </a>
                <a href="toZIP">
                    <button type="button">ZIP</button>
                </a>
                
            </div>
        </div>
    </td>
    */
    let selectionContents = [];

    let viewDivContents = [];
    if (typeDesc.gltf) {
        let viewerURL = viewURL + '?b=' + oar + '&v=' + type;
        let viewLink = makeLink(viewerURL, makeButton('View'));
        viewLink.setAttribute('target', '_blank');
        viewDivContents.push(makeDiv(viewLink, 'c-viewer'));
    }
    selectionContents.push(makeDiv(viewDivContents, 'c-viewer'));

    let downloadDivContents = [];
    downloadDivContents.push(makeDiv('Download:'));
    if (typeDesc.tgz) {
        downloadDivContents.push(makeLink(baseURL + oar + '/' + type + '/' + typeDesc.tgz, makeButtonSmall('TGZ')));
    }
    if (typeDesc.zip) {
        downloadDivContents.push(makeLink(baseURL + oar + '/' + type + '/' + typeDesc.zip, makeButtonSmall('ZIP')));
    }
    selectionContents.push(makeDiv(downloadDivContents, 'c-downloads'));

    return makeData(makeDiv(selectionContents, 'c-selection'), 'c-col-selection');
};

function makeButton(label, ref) {
    let but = makeElement('button', label, 'button clickable');
    but.setAttribute('type', 'button');
    if (ref) {
        but.setAttribute('c-op', 'view');
        but.setAttribute('c-ref', ref);
    }
    return but;
}

function makeButtonSmall(label, ref) {
    let but = makeElement('button', label, 'button-sm clickable');
    but.setAttribute('type', 'button');
    if (ref) {
        but.setAttribute('c-op', 'view');
        but.setAttribute('c-ref', ref);
    }
    return but;
};

function makeLink(url, contents, aClass) {
    let anchor = makeElement('a', contents, aClass);
    anchor.setAttribute('href', url);
    return anchor;
};

function makeTable(contents, aClass) {
    return makeElement('table', contents, aClass);
};

function makeRow(contents, aClass) {
    return makeElement('tr', contents, aClass);
};

function makeHeader(contents, aClass) {
    return makeElement('th', contents, aClass);
};

function makeData(contents, aClass) {
    return makeElement('td', contents, aClass);
};

function makeDiv(contents, aClass) {
    return makeElement('div', contents, aClass);
};

function makeImage(src, aClass) {
    let img = makeElement('img', undefined, aClass);
    img.setAttribute('src', src);
    return img;
}

function makeText(contents) {
    let tex = document.createTextNode(contents);
    return tex;
};

// Make a DOM element of 'type'.
// If 'contents' is:
//       undefined: don't add any contents to the created element
//       an array: append multiple children
//       a string: append a DOM text element containing the string
//       otherwise: append 'contents' as a child
// If 'aClass' is defined, add a 'class' attribute to the created DOM element
// Returns the created element
function makeElement(type, contents, aClass) {
    let elem = document.createElement(type);
    if (aClass) {
        elem.setAttribute('class', aClass);
    }
    if (contents) {
        if (Array.isArray(contents)) {
            contents.forEach(ent => {
                if (typeof(ent) != 'undefined') {
                    if (typeof(contents) === 'string') {
                        elem.appendChild(makeText(contents));
                    }
                    else {
                        elem.appendChild(ent);
                    }
                }
            });
        }
        else {
            if (typeof(contents) === 'string') {
                elem.appendChild(makeText(contents));
            }
            else {
                elem.appendChild(contents);
            }
        }
    }
    return elem;
};
