const ini = require('ini');
const fs = require('fs');
const path = require('path');
const shapefile = require("shapefile");
const csvParser = require("csv-parser");
const dbf = require("dbf-reader");

const ATTRIBUTES = "_attributes";
const innerDbfs = ["POD_C","PL_AP","PL_SL","PL_IS_PL_IS_ELE","QE_DT","QE_FG","QE_M"];
let types = new Map();

readCsvFile(path.join(__dirname,"../","data","mapping.csv"),types);

const cwd = process.cwd();

const ini_path = `${cwd}\\data\\classes.ini`;
const xml_path = `${cwd}\\temp\\PELL.xml`;
let shape_path = `${cwd}\\temp\\shape`;

const typeMapping = ["-99993","-99993.0","15/01/1193","93"];

const config = ini.parse(fs.readFileSync(ini_path, 'utf-8'));

let classid = "";
let newNode = {};
let counter = 0;

let attrMapper = new Map();

async function shape2xml(req, res/*, next*/)
{
   shape_path = path.join(__dirname, "../","temp","shape",req.files.file["name"].replace(".zip",""));

    var xmlObj = {"_declaration":{"_attributes":{"version":"1.0","encoding":"utf-8"}}};
    xmlObj["CensusTechSheet"] = {"_attributes":
            {
                "xmlns:ns1": "http://www.opengis.net/gml/3.2",
                "xmlns:ns2":"http://www.w3.org/1999/xlink",
                "xmlns:ns4": "http://www.isotc211.org/2005/gco",
                "xmlns:ns5": "http://www.isotc211.org/2005/gmd",
                "xmlns:ns6": "http://www.isotc211.org/2005/gts",
                "xmlns:xsi":"http://www.w3.org/2001/XMLSchema-instance", 
                "xsi:noNamespaceSchemaLocation":"../../xsd/CensusTechSheet.xsd",
                "xmlns:gml":"http://www.opengis.net/gml/3.2", 
                "xmlns:xlink":"http://www.w3.org/1999/xlink"
            }};

    let dbfBuffers = [];

    for(let i = 0; i < innerDbfs.length; i++)
        dbfBuffers[i] = dbfBufferBuilder(path.join(shape_path,`${innerDbfs[i]}.dbf`));
    
    for (const[key, value] of Object.entries(config))
    {
        if(innerDbfs.includes(key))
           attrMapper.set(key,value.Attr);
        
        if (!(value.Node in xmlObj))
            xmlObj["CensusTechSheet"][value.Node] = [];
      
        if ((value.geometry_type != 'NULL') || (value != undefined))
        {
            if(fs.existsSync(path.join(shape_path,`${key}.shp`)))
            {
                shapefile.open(path.join(shape_path,`${key}`))
                    .then(source => source.read()
                    .then(function log(result)
                    {         
                        if (result.done)
                        {
                            console.log(`Server Log: Processing: {${key}} ended successfully`);
                            return;
                        } 

                        if(value['CLASSID'] !== undefined)
                            classid = value['CLASSID'].split(":")[0];
                        
                        let shape = result.value;
                        let coordinates = [];
                        let flattenCoord = "";

                        if(result.value["geometry"]["type"] === "Polygon")
                        {
                            coordinates = result.value["geometry"]["coordinates"][0].flat();
                            flattenCoord = "";

                            coordinates.forEach(item => flattenCoord += `${item} `);

                            newNode["ns1:Polygon"] =
                            {
                                _attributes:
                                {
                                    srsName: "http://www.opengis.net/def/crs/EPSG/8.5/4326",
                                    srsDimension: "2"
                                },
                                "ns1:exterior": 
                                {
                                    "ns1:LinearRing": 
                                    {
                                        "ns1:posList": 
                                        {
                                            _text: flattenCoord
                                        }
                                    }                            
                                }
                            };
                        }else
                        {
                            coordinates = result.value["geometry"]["coordinates"].flat();
                            flattenCoord = "";
                            coordinates.forEach(item => flattenCoord += `${item} `);
                            newNode[classid] =
                            {
                                "ns1:Point":
                                {
                                    _attributes: 
                                    {
                                        srsName: "http://www.opengis.net/def/crs/EPSG/8.5/4326",
                                        srsDimension: "2" 
                                    },
                                    "ns1:pos": 
                                    {
                                        _text: flattenCoord
                                    }
                                }
                            }
                        }   

                        value.Attr.split('|').forEach(element =>
                        {
                            let a = element.split(':');

                            xmlNodeBuilder(a.length,newNode,a,shape.properties[a[a.length-1]]);

                            if(shape.properties[a[a.length-1]] !== undefined) 
                                xmlNodeBuilder(a.length,newNode,a,shape.properties[a[a.length-1]]);
                            else if(shape.properties[a[a.length-1].toLowerCase()] !== undefined)
                                xmlNodeBuilder(a.length,newNode,a,shape.properties[a[a.length-1].toLowerCase()]);
                        });

                        switch(value.Node)
                        {
                            case "POD":
                                innerNodeXmlBuilder(dbfBuffers[0],attrMapper.get(innerDbfs[0]),counter);
                                break;
                            case "LightSpot":                                
                                for(let i = 0; i < dbfBuffers.length; i++)
                                    innerNodeXmlBuilder(dbfBuffers[i],attrMapper.get(innerDbfs[i]),counter);
                                break;
                            case "ElectricPanel":
                                for(let i = 4; i < dbfBuffers.length; i++)
                                    innerNodeXmlBuilder(dbfBuffers[i],attrMapper.get(innerDbfs[i]),counter);
                                break;
                            }
                        counter++;
                
                        xmlObj["CensusTechSheet"][value.Node].push(newNode);
                        
                        writeXmlFile(xml_path,xmlObj);
                        newNode = {};
                        counter = 0;

                        source.read().then(log)
                        return;
                })).catch(error => console.error(`Server Error: ${error.stack}\n\n\t**********Error**********`));
            }
            else
            {
                if(key === "ZO")
                {
                    let buffer = fs.readFileSync(path.join(shape_path,`${key}.dbf`));

                    if(buffer)
                        t = dbf.Dbf.read(buffer);
    
                    console.log("************************************\n");
                    console.log(key)
                    let elementArr = [];
                    value.Attr.split("|").forEach(element => elementArr.push(element.split(":")));
    
                    for(let i = 0; i < t.rows.length; i++)  
                    {   
                        for(let j = 0; j < elementArr.length; j++)
                        {
                            if(t.rows[i][elementArr[j][elementArr[j].length - 1]] !== undefined) 
                                xmlNodeBuilder(elementArr[j].length,newNode,elementArr[j],t.rows[i][elementArr[j][elementArr[j].length - 1]]);
                            else if(t.rows[i][elementArr[j][elementArr[j].length - 1].toLowerCase()] !== undefined)
                                xmlNodeBuilder(elementArr[j].length,newNode,elementArr[j],t.rows[i][elementArr[j][elementArr[j].length - 1].toLowerCase()]);
                        }
                         
                        xmlObj["CensusTechSheet"][value.Node].push(newNode);
    
                        writeXmlFile(xml_path,xmlObj);    
                        newNode = {};
                    }
                }
            }
        }        
    }
    console.log("literally out")
}

function innerNodeXmlBuilder(fileBuffer,attributes,cnt)
{
    let attrs = attributes.split("|");
    let elements = [];
    attrs.forEach(attr => elements.push(attr.split(":")))

    for(let j = 0; j < elements.length; j++)
    {
        if(fileBuffer.rows[cnt][elements[j][elements[j].length - 1]] !== undefined) 
            xmlNodeBuilder(elements[j].length,newNode,elements[j],fileBuffer.rows[cnt][elements[j][elements[j].length - 1]]);
        else if(fileBuffer.rows[cnt][elements[j][elements[j].length - 1].toLowerCase()] !== undefined)
            xmlNodeBuilder(elements[j].length,newNode,elements[j],fileBuffer.rows[cnt][elements[j][elements[j].length - 1].toLowerCase()]);
    }   
}

function xmlNodeBuilder(len,currentNode,attributes,element)
{
    switch(len)
    {
        case 2:  
            if (!currentNode.hasOwnProperty(attributes[0]))
                currentNode[attributes[0]] = {}; 

            if(element === undefined || element === "Non definito")
                currentNode[attributes[0]]["_text"] = typeChecking(types.get(attributes[0]),typeMapping);
            else
                currentNode[attributes[0]]["_text"] = element;

            attributesAdder(attributes[0],currentNode[attributes[0]]);

            break; 
        case 3:
            if (!currentNode.hasOwnProperty(attributes[0]))
                currentNode[attributes[0]] = {};

            if (!currentNode[attributes[0]].hasOwnProperty(attributes[1]))
                currentNode[attributes[0]][attributes[1]] = {};

            if(element === undefined || element === "Non definito")
                currentNode[attributes[0]][attributes[1]]["_text"] = typeChecking(types.get(attributes[1]),typeMapping);
            else
                currentNode[attributes[0]][attributes[1]]["_text"] = element;
            
            attributesAdder(attributes[1],currentNode[attributes[0]][attributes[1]]);

            break;
        case 4:
            if (!currentNode.hasOwnProperty(attributes[0]))
                currentNode[attributes[0]] = {};
            if (!currentNode[attributes[0]].hasOwnProperty(attributes[1]))
                currentNode[attributes[0]][attributes[1]] = {};
            if (!currentNode[attributes[0]][attributes[1]].hasOwnProperty(attributes[3]))
                currentNode[attributes[0]][attributes[1]][attributes[2]] = {};

            if(element === undefined || element === "Non definito")
                currentNode[attributes[0]][attributes[1]][attributes[2]]["_text"] = typeChecking(types.get(attributes[2]),typeMapping);
            else
                currentNode[attributes[0]][attributes[1]][attributes[2]]["_text"] = element;

            attributesAdder(attributes[2],currentNode[attributes[0]][attributes[1]][attributes[2]]);

            break;
    }
}

function writeXmlFile(path,xmlObject)
{
    let convert = require('xml-js');
    let options = {compact: true, ignoreComment: true, spaces: 4};
    let result = convert.js2xml(xmlObject, options);
    fs.writeFileSync(path, result);
    
}

function attributesAdder(xmlTagName,currentNode)
{
    switch(xmlTagName)
    {
        case "Surface":
            currentNode[ATTRIBUTES] =
            {
                uom: "km2"
            }
            break;
        case "InstalledPower":
            currentNode[ATTRIBUTES] =
            {
                uom: "kW",
            }
            break;
        case "PreviousYearAnnualConsumption":
            currentNode[ATTRIBUTES] =
            {
                uom: "kWh"
            }
            break;
        case "ContractuallyCommittedPower":
            currentNode[ATTRIBUTES] =
            {
                uom: "kW"
            }
            break;
        case "ElectricPanelInstalledPower":
            currentNode[ATTRIBUTES] =
            {
                uom: "kW"
            }
            break;
        case "NominalVoltage":
            currentNode[ATTRIBUTES] =
            {
                uom: "V"
            }
            break;
        case "TransformerPower":
            currentNode[ATTRIBUTES] =
            {
                uom: "kV*A"
            }
            break;
        case "Height":
            currentNode[ATTRIBUTES] =
            {
                uom: "m"
            }
            break;
        case "Incline":
            currentNode[ATTRIBUTES] =
            {
                uom: "°"
            }
            break;
        case "Distance":
            currentNode[ATTRIBUTES] =
            {
                uom: "m"
            }
            break;
        case "length":
            currentNode[ATTRIBUTES] =
            {
                uom: "m"
            }
            break;
        case "TerminalPower":
            
            currentNode[ATTRIBUTES] =
            {
                uom: "W"
            }
            break;
        case "UpwardEmission":
            
            currentNode[ATTRIBUTES] =
            {
                uom: "cdklm"
            }
            break;
        case "Flux":
            currentNode[ATTRIBUTES] =
            {
                uom: "lm"
            }
            break;
        case "NominalLuminousFlux":
            currentNode[ATTRIBUTES] =
            {
                uom: "lm"
            }
            break;
        case "NominalPower":
            currentNode[ATTRIBUTES] =
            {
                uom: "W"
            }
            break;
        case "CCT": 
            currentNode[ATTRIBUTES] =
            {
                uom: "k"
            }
            break;
        case "AeraSurface":
            currentNode[ATTRIBUTES] =
            {
                uom: "m2"
            }
            break;
        case "FootpathWidth":
            currentNode[ATTRIBUTES] =
            {
                uom: "m"
            }
            break;
        case "DistanceBetweenLightSpots":
            currentNode[ATTRIBUTES] =
            {
                uom: "m"
            }
            break;
        case "OtherFootpathWidth":
            currentNode[ATTRIBUTES] =
            {
                uom: "m"
            }
            break;
    }
}

function typeChecking(keyToCheck,values)
{
    let result = "";

    switch(keyToCheck)
    {
        case "String":
            result = values[0];
            break;
        case "int":
            result = values[0];
            break;
        case "double":
            result = values[1];
            break;
        case "date":
            result = values[2];
            break;
        case "bool":
            result = values[3];
            break;
        case undefined:
            result = "";
            break;
    }
    return result;
}

function dbfBufferBuilder(filePath)
{
    let buffer = fs.readFileSync(filePath);

    if(buffer)
         return dbf.Dbf.read(buffer);
}

function readCsvFile(path,map)
{
    fs.createReadStream(path)
    .pipe(csvParser())
    .on('data',(data) =>
    {
        map.set(data['Key'],data['Value']);
    }).on('end',() =>
    {
      console.log("Mapping successfully loaded")
    });   
}

module.exports = 
{
    shape2xml
}