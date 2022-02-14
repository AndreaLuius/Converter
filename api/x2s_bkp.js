var fs = require('fs');
var he = require('he');
var validator = require('xsd-schema-validator');
var xml_parser = require('fast-xml-parser');
const { NONAME } = require('dns');
const path = require('path');
const ini = require('ini');
const shpwrite = require('shp-write');
const dbf = require('dbf');

const cwd = process.cwd();

//const xml_path = `${cwd}\\data\\PELL_xml_NeMeA_validato.xml`
const xml_path = `${cwd}\\data\\SchedaCensimentoV2.xml`
const xsd_path = `${cwd}\\data\\xsd\\CensusTechSheet.xsd`
const tmp_path = `${cwd}\\temp`
const ini_path = `${cwd}\\data\\classes.ini`

const config = ini.parse(fs.readFileSync(ini_path, 'utf-8'));

var options_fast_xml_parser = {
  attributeNamePrefix : "@_",
  attrNodeName: "attr", //default is 'false'
  textNodeName : "#text",
  ignoreAttributes : false,
  ignoreNameSpace : true,
  allowBooleanAttributes : false,
  parseNodeValue : true,
  parseAttributeValue : false,
  trimValues: true,
  cdataTagName: "__cdata", //default is 'false'
  cdataPositionChar: "\\c",
  parseTrueNumberOnly: false,
  arrayMode: false, //"strict"
  attrValueProcessor: (val, attrName) => he.decode(val, {isAttributeValue: true}),//default is a=>a
  tagValueProcessor : (val, tagName) => he.decode(val), //default is a=>a
  stopNodes: ["parse-me-as-string"]
};

var shapename = '';
var timestamp = ''+Date.now();


function shpcallback(err, obj){
  if (err) {console.log("------ERROR-------");console.log(err); return;}      
  for (const[key, value] of Object.entries(obj)){
    //console.log(Object.getOwnPropertyNames(value));
    //console.log(value);
    //console.log(path.join(tmp_path,shapename+'.'+key));
    //console.log(value["buffer"]);    
    if (!fs.existsSync(path.join(tmp_path, timestamp))){
      fs.mkdirSync(path.join(tmp_path, timestamp));
    }

    if (key=='prj')
      fs.appendFileSync(path.join(tmp_path, timestamp, shapename+'.'+key), Buffer.from(value));
    else
      fs.appendFileSync(path.join(tmp_path, timestamp, shapename+'.'+key), Buffer.from(value["buffer"]));
  } 
  //console.log('-----OBJ----');
  //console.log(obj);
}

function toBuffer(ab) {
  let buffer = new Buffer(ab.byteLength);
  let view = new Uint8Array(ab);
  for (let i = 0; i < buffer.length; ++i) {
      buffer[i] = view[i];
  }
  return buffer;
}


function xml2shape(req, res, next) {
  /*
  //fast xml parser
  fs.readFile(xsd_path, "utf8", function(err, data) {
    console.log("File Loaded!!");

    if (err) {
      return next(err);
    }

    // fast xml parser
    // if( parser.validate(xml_path) === true) { //optional (it'll return an object in case it's not valid)
    //     var jsonObj = parser.parse(xml_path,options_fast_xml_parser);
    // }

    // Intermediate obj
    console.log("Start parsing");
    console.time("test");
    var tObj = xml_parser.getTraversalObj(data,options_fast_xml_parser);
    var jsonObj = xml_parser.convertToJson(tObj,options_fast_xml_parser);
    console.log("Done");
    var root = Object();
    for (const [key, value] of Object.entries(jsonObj)) {
      if (key =="xsd:schema"){root = value;}
    }
    var element = Object();
    var complexType = Object();
    var simpleType = Object();
    for (const [key, value] of Object.entries(root)) {
      switch(key){
        case "xsd:element":
          element = value;
          break;
        case "xsd:complexType":
          complexType = value;
          break;
        case "xsd:simpleType":
          simpleType = value;
          break;
      }
    }
    var shapeStruct = Object();
    var node = element.find(n=> n.attr['@_name'] === "CensusTechSheet");
    //console.log(node);
    //----------------------GET SHAPENAME-------------------------//
    var shapes = complexType.find(n=> n.attr['@_name'] === node.attr['@_type']);
    for (const [key, value] of Object.entries(shapes['xsd:sequence']['xsd:element'])){
      var current_node = value;
      let type = element.find(n=> n.attr['@_name'] === value.attr['@_ref']);
      type = type.attr['@_type']
      console.log(current_node);
      
      if (typeof value['xsd:annotation']['xsd:documentation'].Label != "undefined"){
 
        label = value['xsd:annotation']['xsd:documentation'].Label;
        shapeStruct[label] = Object();
        shapeStruct[label]['ref'] = value.attr['@_ref'];
      } else {
        console.log('----------------secondo livello------------------')
        console.log(type);
        if (type == 'PLSystemGeneralDataType') continue;
        current_node = complexType.find(n=> n.attr['@_name'] === type);
        console.log(current_node);
        
        
        for (const [k, v] of Object.entries(current_node['xsd:sequence']['xsd:element'])){
          console.log(v);
          if (typeof v['xsd:annotation']['xsd:documentation'].Label != "undefined"){
 
            label = v['xsd:annotation']['xsd:documentation'].Label;
            shapeStruct[label] = Object();
            shapeStruct[label]['ref'] = v.attr['@_ref'];
          }
        }
        
        //console.log(current_node);
      }
    }
    console.log(shapeStruct);
    console.log('xsd done');
  });

  */

 
  // reading XML file
  fs.readFile(xml_path, "utf8", function(err, data) {

    console.log('Parse XML - Starting...');
    console.time("XML");
    if (err) {
      return next(err);
    }
    var tObj = xml_parser.getTraversalObj(data,options_fast_xml_parser);
    var jsonObj = xml_parser.convertToJson(tObj,options_fast_xml_parser);
    var root = Object();
    for (const [key, value] of Object.entries(jsonObj)){
      if (key =="CensusTechSheet"){root = value;}
    }
    console.log("Parse XML - Done");
    console.timeEnd("XML");
    //console.log(root);   

    console.log ('start creating shapefiles...')  
    //cicla sulle sezioni/shape
    for (const[key, value] of Object.entries(config)){
      //console.log(value);
      var shapefile = {};
      shapefile.name = key;
      shapefile.geometry_type = value.Geometry.split(':').slice(-1)[0];
      shapefile.rows = [];
      shapefile.geometries = [];

      for (const [k, v] of Object.entries(root)){
        if (k==value.Node){
          console.log(value.Node+" found.");
          let features = [];
          if (v.length===undefined)
            features.push(v);
          else
            features = v;
          console.log(features.length+" features founded");

          features.forEach(feature => {
            let geometry_path = value.Geometry.split(':');
            let classid = [];
            let classref = [];
            if ('CLASSID' in value) classid = value.CLASSID.split(':');
            if ('CLASSREF' in value) classref = value.CLASSREF.split(':');

			//try {
            switch(shapefile.geometry_type){
              case 'NULL':
                break;
              case 'Polygon':
                let coord = [];
                let polygon = [];
                let point = [];
                if (geometry_path.hasOwnProperty(1))  {              
                  coord = feature[geometry_path[0]][geometry_path[1]].exterior.LinearRing.posList.split(' ').reverse().map(Number);
					console.log(feature[geometry_path[0]][geometry_path[1]].exterior.LinearRing.posList.split(' ').reverse().toString());}
                else {              
                  coord = feature[geometry_path[0]].exterior.LinearRing.posList.split(' ').reverse().map(Number);
				  console.log(feature[geometry_path[0]].exterior.LinearRing.posList.split(' ').reverse().toString())
				}
                for (const property in coord) {
                    if (property % 2){
                      //point.splice(0, 0, coord[property]);
                      point.push(coord[property]);
                      polygon.push(point);                   
                    } else {
                      point = [coord[property]];  
                    }
                }                
                //shapefile.geometries = [[[1,0], [1,1], [0,1], [0,0], [1,0]]];
                shapefile.geometries.push(polygon);
                break;
              case 'Point':
                if (geometry_path.hasOwnProperty(1)){
                  shapefile.geometries.push(feature[geometry_path[0]][geometry_path[1]].pos.split(' ').reverse().map(Number));
				  //console.log(feature[geometry_path[0]][geometry_path[1]].pos.split(' ').reverse().toString())
				}
                else{
                  shapefile.geometries.push(feature[geometry_path[0]].pos.split(' ').map(Number));
				}
                break;
              default:
                console.log('Geometry '+shapefile.geometry_type+' not supported');
            }
			//}catch (error) {  console.error(error);
			//}
            
            //set attribute feature
            let data = Object();            
/*
            if ('CLASSID' in value) {
              if (classid.hasOwnProperty(1))
                data['CLASSID'] = feature[classid[0]][classid[1]].attr['@_id'];
              else
                data['CLASSID'] = feature[classid[0]].attr['@_id'];
            }
            */
            if ('CLASSID' in value) {
              let node = feature;
              //console.log(node);              
              for (let i = 0; i < classid.length; i++) {        
                node = node[classid[i]];
              }
              data['CLASSID'] = node.attr['@_id'];
            }
            
            if ('CLASSREF' in value) {
              let node = feature
              for (let i = 0; i < classref.length; i++) {        
                node = node[classref[i]];
              }
              data['CLASSREF'] = node.attr['@_id'];
            }          
              
            value.Attr.split('|').forEach(element => {
              let a = element.split(':')
              let node = feature;
              for (let i = 0; i < a.length-1; i++) {
                if (node.hasOwnProperty(a[i]))
                  node = node[a[i]];
              }
              if (!Array.isArray(node) && !(typeof node === 'object') && node !== null)
                data[a[a.length-1]] = node.toString();
              /*
              if (a.hasOwnProperty(2))          
                data[a[2]]=((!(a[0] in feature) || !(a[1] in feature[a[0]]))? '' : feature[a[0]][a[1]] );
              else
                data[a[1]]=(!(a[0] in feature)? '' : feature[a[0]] );
                */
            });
            shapefile.rows.push(data);
          });
        }
      } 
      //console.log(shapefile);
      shapename = shapefile.name;
      if (shapefile.geometry_type=='NULL'){
        let buf = dbf.structure(shapefile.rows);
        fs.appendFileSync(path.join(tmp_path,timestamp,shapename+'.dbf'), toBuffer(buf.buffer));
      }else{
		  try{
        shpwrite.write(shapefile.rows, shapefile.geometry_type.toUpperCase(), shapefile.geometries, shpcallback);
		  }catch (error) {
		  console.error(error);}
      }
    }
    res.send({mainKey: Object.keys(jsonObj)})    
  });
}

function validate_xml_sch(req, res, next) {
  res.send({todo: "TODO!"});
}

/* function check_label(node, single){
  console.log('checklabel');
  console.log(node);
  let label = node.find(n=> n['xsd:annotation']['xsd:documentation'].Label);

  console.log('-------------LABEL---------------');
  console.log(label);
  return label
} */

module.exports = {
  xml2shape
}