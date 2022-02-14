const fileUpload = require("express-fileupload");
const fs = require("fs");
const decompress = require("decompress");
const path = require("path");
const fsExtra = require("fs-extra");
const util = require("util");
const xml2Shape = require('../api/xml2Shape');
const shape2xml = require('../api/shape2xml');

const STATIC_XML_LOCATION = "data";
const STATIC_SHAPE_LOCATION = "temp/shape";
const paths = [path.join(__dirname,"../","dest"),path.join(__dirname,"../","temp","shape")];


async function moveIfPresent(dirPath,xmlOldPath,xmlNewPath,format,func)
{
  let found = false;
  let files = fs.readdirSync(dirPath);

  files.forEach(currentFile => 
  {
    if(currentFile.includes(format))
    {
      console.log("xml found");
      fs.renameSync(`${xmlOldPath}/${currentFile}`,`${xmlNewPath}/${currentFile}`);
      found = true;
    }
  });

  if(!found)
    func();

  return new Promise((resolve,reject) => resolve(found));

}

function homePage(req,res)
{
  res.sendFile(path.join(__dirname,"../","static","index.html"));
};

async function convert(req,res)
{
  if(req.files)
  {
    const file = req.files.file;
    const filename = file.name;
    
    if(filename.includes(".xml"))
    {
      file.mv(path.join(__dirname,"../","dest",filename),err =>
      {
        if(err) throw err;
        
        xml2Shape.xml2shape(req,res);
        res.download(path.join(__dirname,"../","temp","PELL.xml"));
      });
    }
    else if (filename.includes(".zip"))
    {
      file.mv(path.join(__dirname,"../","dest",filename), function(err)
      {
          console.log("moving zip file to dest" +path.join(__dirname,"../","dest",filename));
          if(err) res.json(err);

          let plainFile = filename.replace(".zip","");

          decompress(`./dest/${filename}`,`./dest/${plainFile}`).then(files =>
          {
            const checkFile = fs.readdirSync(path.join(__dirname,"../","dest",plainFile));
            
            if(checkFile.length > 0)
            {
              if(!checkFile[0].includes("."))
              {
                throw Error("The file you sent contains a subfolder please retry with a single node");
              }
              else
              {
                moveIfPresent(path.join(__dirname,"../","dest",plainFile),
                  path.join(__dirname,"../","dest",plainFile),
                  path.join(__dirname,"../",STATIC_XML_LOCATION),".xml",() => 
                  {
                    if(!fs.existsSync(path.join(__dirname,"../",STATIC_SHAPE_LOCATION,plainFile)))
                    {
                      fsExtra.moveSync(path.join(__dirname, "../","dest",plainFile),
                            path.join(__dirname,"../",STATIC_SHAPE_LOCATION,plainFile));
                    }
                    else
                    {
                      fs.rmdirSync(path.join(__dirname,"../",STATIC_SHAPE_LOCATION,plainFile),{recursive: true});
                      
                      fsExtra.moveSync(path.join(__dirname, "../","dest",plainFile),
                            path.join(__dirname,"../",STATIC_SHAPE_LOCATION,plainFile));
                    }

                    let resu = shape2xml.shape2xml(req,res);

                    let interval = setInterval(() => {
                      if(resu)
                      { 
                        clearInterval(interval);
                        res.download(path.join(__dirname,"../","temp","PELL.xml"));
                        return;
                      }
                    }, 1000);
                }).then(val =>
                  {
                    if(val === true)
                    {
                      xml2Shape.xml2shape(req,res).then(flName => 
                      {
                        res.download(path.join(__dirname,"../","temp",flName));
                      });
                    }
                  });
              }
            }
          }); 
      });
    }
  }
}

function clear(pathToClear)
{
  let foundFiles;

  foundFiles = fs.readdirSync(pathToClear);
  
  foundFiles.forEach((currentFile) => fs.unlinkSync(path.join(pathToClear,currentFile)));
}

module.exports =
{
    homePage,
    convert,
};