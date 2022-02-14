var fs = require('fs');
var he = require('he');
var xml_parser = require('fast-xml-parser');
const path = require('path');
const ini = require('ini');
const shpwrite = require('shp-write');
const dbf = require('dbf');
const zipper = require("folder-zip-sync");


const cwd = process.cwd();

// let xml_path = `${cwd}\\data\\PELL.xml`;
const xsd_path = `${cwd}\\data\\xsd\\CensusTechSheet.xsd`;
const tmp_path = `${cwd}\\temp`;
const ini_path = `${cwd}\\data\\classes.ini`;

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
var timestamp = '' + Date.now();
// var timestamp = "PellShape";

function shpcallback(err, obj){
  if (err) {console.err(err); return;} 

  for (const[key, value] of Object.entries(obj))
  {    
    if (!fs.existsSync(path.join(tmp_path, timestamp)))
      fs.mkdirSync(path.join(tmp_path, timestamp));

    if (key === 'prj')
      fs.appendFileSync(path.join(tmp_path, timestamp, shapename+'.'+key), Buffer.from(value));
    else
      fs.appendFileSync(path.join(tmp_path, timestamp, shapename+'.'+key), Buffer.from(value["buffer"],"base64"));
  } 
}

function toBuffer(ab)
{
  let buffer = Buffer.alloc(ab.byteLength);
  let view = new Uint8Array(ab);

  for (let i = 0; i < buffer.length; ++i)
      buffer[i] = view[i];
  
  return buffer;
}


async function xml2shape(req, res) {

  let endpFileName = req.files.file.name;
  const reqFile = (endpFileName.includes(".zip")) ? 
        endpFileName.replace(".zip",".xml") : endpFileName; 
  
  console.log(reqFile)
  let xml_path = path.join(__dirname, "../", "data", reqFile);


  // reading XML file
  // fs.readFile(xml_path, "utf8", function(err, data) {

  //   console.log('Parse XML - Starting...');
  //   // console.time("XML");

  //   var tObj = xml_parser.getTraversalObj(data,options_fast_xml_parser);
  //   var jsonObj = xml_parser.convertToJson(tObj,options_fast_xml_parser);
  //   var root = Object();
  //   var temp = Number();

  //   for (const [key, value] of Object.entries(jsonObj)){
  //     if (key =="CensusTechSheet"){root = value;}
  //   }
  //   console.log("Parse XML - Done");
  //   // console.timeEnd("XML");
  //   //console.log(root);   

  //   // console.log ('start creating shapefiles...')  
  //   //cicla sulle sezioni/shape
  //   for (const[key, value] of Object.entries(config)){
  //     var shapefile = {};
  //     shapefile.name = key;
  //     shapefile.geometry_type = value.Geometry.split(':').slice(-1)[0];
  //     shapefile.rows = [];
  //     shapefile.geometries = [];

  //     for (const [k, v] of Object.entries(root))
  //     {

  //       if (k==value.Node){

  //         // console.log(value.Node+" found.");
  //         let features = [];

  //         if (v.length===undefined)
  //           features.push(v);
  //         else
  //           features = v;
  //         // console.log(features.length+" features founded");

  //         features.forEach(feature =>
  //         {
  //           let geometry_path = value.Geometry.split(':');
  //           let classid = [];
  //           let classref = [];
  //           if ('CLASSID' in value) classid = value.CLASSID.split(':');
  //           if ('CLASSREF' in value) classref = value.CLASSREF.split(':');

  //           switch(shapefile.geometry_type)
  //           {
  //             case 'NULL':
  //               break;
  //             case 'Polygon':
  //               // console.log("Log: Properties Polygon started loading");
  //               let coord = [];
  //               let polygon = [];
  //               let point = [];
	// 		        	const lista = [];

  //               if (geometry_path.hasOwnProperty(1))
  //                 coord = feature[geometry_path[0]][geometry_path[1]].exterior.LinearRing.posList.split(' ').map(Number);      
  //               else   
  //                   coord = feature[geometry_path[0]].exterior.LinearRing.posList.split(' ').map(Number);     
  //               for (const property in coord)
  //               {
  //                   if (property % 2)
  //                   {
	// 				            pointTemp = [coord[temp],coord[property]]
  //                     polygon.push(pointTemp);        
  //                   } 
  //                   else 
  //                      point = [coord[temp],coord[property]];  

	// 			          	temp=property
  //               }    

  //               let arraya = [];
  //               arraya.push(polygon);
                
  //               shapefile.geometries.push(arraya);
  //               break;
  //             case 'Point':
  //               if (geometry_path.hasOwnProperty(1))
  //                     shapefile.geometries.push(feature[geometry_path[0]][geometry_path[1]].pos.split(' ').map(Number));
  //               else
  //                 shapefile.geometries.push(feature[geometry_path[0]].pos.split(' ').map(Number));
  //               break;
  //             default:
  //               console.log('Geometry '+shapefile.geometry_type+' not supported');
  //           }
	
  //           //set attribute feature
  //           let data = Object();  
  //           {
  //             // if ('CLASSID' in value) 
  //             // {
  //             //   let node = feature;

  //             //   for (let i = 0; i < classid.length; i++)
  //             //     node = node[classid[i]];
  //             //   // console.log(node.attr);

  //             //   if(node.attr)
  //             //   {
  //             //     if(node.attr.hasOwnProperty('@_id'))
  //             //       data['CLASSID'] = node.attr['@_id']; 
  //             //   }
  //             // }
              
  //             // if ('CLASSREF' in value)
  //             // {
  //             //   let node = feature
  //             //   for (let i = 0; i < classref.length; i++)        
  //             //     node = node[classref[i]];
                
  //             //   if(node.attr)
  //             //   {
  //             //     if(node.attr.hasOwnProperty("@_id"))
  //             //       data['CLASSREF'] = node.attr['@_id'];
  //             //   }
  //             // }          
  //           }          

          
  //           value.Attr.split('|').forEach(element =>
  //           {
  //             let a = element.split(':');
  //             let node = feature;
              
  //             for (let i = 0; i < a.length-1; i++)
  //             {
  //               if (node.hasOwnProperty(a[i]))
  //               {
  //                 a[i].trim();
  //                 let newNode = {};

  //                 for(const prop in node[a[i]])
  //                 {
                  
  //                   if(node[a[i]].hasOwnProperty(prop.toString()))
  //                   {
                      
  //                     if(typeof node[a[i]][prop] === 'object')
  //                     {
  //                       newNode = node[a[i]][prop];
                        
  //                       if(newNode['#text'] !== undefined)
  //                         node[a[i]][prop] = newNode['#text']; 
  //                       else
  //                       {
  //                         newNode['#text'] = "Non definito";
  //                         node[a[i]][prop] = newNode['#text'];
  //                       }
  //                     }
  //                   }
  //                 }
  //                 node = node[a[i]];
  //               }
  //             }
  //             if (!Array.isArray(node) &&  node !== null)
  //             {
  //               if(typeof node === 'object')
  //               {
  //                 for(const e in node)
  //                 {
  //                   if(node[e] !== undefined)
  //                   {
  //                     if(e === "attr")
  //                       data[a[a.length-1]] = (node["#text"] === undefined) ? "Non definito" : node["#text"];
  //                     else
  //                       data[a[a.length-1]] = node[e];
  //                   }   
  //                 }
  //               }
  //               else
  //                data[a[a.length-1]] = (node.toString().trim() === undefined) ? "" : node.toString().trim();
  //             }
  //           });
  //           shapefile.rows.push(data);
  //         });
  //       }
  //     } 
  //     shapename = shapefile.name;
      
  //     if (shapefile.geometry_type === 'NULL')
  //     {
  //       let buf = dbf.structure(shapefile.rows);

  //       fs.appendFileSync(path.join(tmp_path,timestamp,`${shapename}.dbf`), toBuffer(buf.buffer));
  //     }
  //     else
  //     {
  //       try
  //       {
  //         shpwrite.write(shapefile.rows, shapefile.geometry_type.toUpperCase(), shapefile.geometries, shpcallback);
  //       }catch (error)
  //       {
  //         console.error(error);
  //       }
  //     }
  //   }
  //   res.send({mainKey: Object.keys(jsonObj)});
  //   console.log("completed");    
  // });


    let data = fs.readFileSync(xml_path,"utf-8");

    console.log('Parse XML - Starting...');
    // console.time("XML");

    var tObj = xml_parser.getTraversalObj(data,options_fast_xml_parser);
    var jsonObj = xml_parser.convertToJson(tObj,options_fast_xml_parser);
    var root = Object();
    var temp = Number();

    for (const [key, value] of Object.entries(jsonObj)){
      if (key =="CensusTechSheet"){root = value;}
    }
    console.log("Parse XML - Done");
    // console.timeEnd("XML");
    //console.log(root);   

    // console.log ('start creating shapefiles...')  
    //cicla sulle sezioni/shape
    for (const[key, value] of Object.entries(config))
    {
      var shapefile = {};
      shapefile.name = key;
      shapefile.geometry_type = value.Geometry.split(':').slice(-1)[0];
      shapefile.rows = [];
      shapefile.geometries = [];

      for (const [k, v] of Object.entries(root))
      {

        if (k==value.Node){

          // console.log(value.Node+" found.");
          let features = [];

          if (v.length===undefined)
            features.push(v);
          else
            features = v;
          // console.log(features.length+" features founded");

          features.forEach(feature =>
          {
            let geometry_path = value.Geometry.split(':');
            let classid = [];
            let classref = [];
            if ('CLASSID' in value) classid = value.CLASSID.split(':');
            if ('CLASSREF' in value) classref = value.CLASSREF.split(':');

            switch(shapefile.geometry_type)
            {
              case 'NULL':
                break;
              case 'Polygon':
                // console.log("Log: Properties Polygon started loading");
                let coord = [];
                let polygon = [];
                let point = [];
			        	const lista = [];

                if (geometry_path.hasOwnProperty(1))
                  coord = feature[geometry_path[0]][geometry_path[1]].exterior.LinearRing.posList.split(' ').map(Number);      
                else   
                    coord = feature[geometry_path[0]].exterior.LinearRing.posList.split(' ').map(Number);     
                for (const property in coord)
                {
                    if (property % 2)
                    {
					            pointTemp = [coord[temp],coord[property]]
                      polygon.push(pointTemp);        
                    } 
                    else 
                       point = [coord[temp],coord[property]];  

				          	temp=property
                }    

                let arraya = [];
                arraya.push(polygon);
                
                shapefile.geometries.push(arraya);
                break;
              case 'Point':
                if (geometry_path.hasOwnProperty(1))
                      shapefile.geometries.push(feature[geometry_path[0]][geometry_path[1]].pos.split(' ').map(Number));
                else
                  shapefile.geometries.push(feature[geometry_path[0]].pos.split(' ').map(Number));
                break;
              default:
                console.log('Geometry '+shapefile.geometry_type+' not supported');
            }
	
            //set attribute feature
            let data = Object();  
   
            value.Attr.split('|').forEach(element =>
            {
              let a = element.split(':');
              let node = feature;
              
              for (let i = 0; i < a.length-1; i++)
              {
                if (node.hasOwnProperty(a[i]))
                {
                  a[i].trim();
                  let newNode = {};

                  for(const prop in node[a[i]])
                  {
                  
                    if(node[a[i]].hasOwnProperty(prop.toString()))
                    {
                      
                      if(typeof node[a[i]][prop] === 'object')
                      {
                        newNode = node[a[i]][prop];
                        
                        if(newNode['#text'] !== undefined)
                          node[a[i]][prop] = newNode['#text']; 
                        else
                        {
                          newNode['#text'] = "Non definito";
                          node[a[i]][prop] = newNode['#text'];
                        }
                      }
                    }
                  }
                  node = node[a[i]];
                }
              }
              if (!Array.isArray(node) &&  node !== null)
              {
                if(typeof node === 'object')
                {
                  for(const e in node)
                  {
                    if(node[e] !== undefined)
                    {
                      if(e === "attr")
                        data[a[a.length-1]] = (node["#text"] === undefined) ? "Non definito" : node["#text"];
                      else
                        data[a[a.length-1]] = node[e];
                    }   
                  }
                }
                else
                 data[a[a.length-1]] = (node.toString().trim() === undefined) ? "" : node.toString().trim();
              }
            });
            shapefile.rows.push(data);
          });
        }
      } 
      shapename = shapefile.name;
      
      if (shapefile.geometry_type === 'NULL')
      {
        let buf = dbf.structure(shapefile.rows);

        fs.appendFileSync(path.join(tmp_path,timestamp,`${shapename}.dbf`), toBuffer(buf.buffer));
      }
      else
      {
        try
        {
          shpwrite.write(shapefile.rows, shapefile.geometry_type.toUpperCase(), shapefile.geometries, shpcallback);
        }catch (error)
        {
          console.error(error);
        }
      }
    }
    console.log(`${timestamp}.zip`)

    zipper(path.join(__dirname,"../","temp",timestamp),path.join(__dirname,"../","temp",`${timestamp}.zip`));
    console.log("completed");
    return `${timestamp}.zip`;
}

function validate_xml_sch(req, res, next) {
  res.send({todo: "TODO!"});
}

module.exports = {
  xml2shape
}