var validator = require('xsd-schema-validator');

//const schema = require('node-schematron');
const cwd = process.cwd();
const sch_validator = require ('schematron-runner');

const xsd_path = `${cwd}\\data\\xsd\\CensusTechSheet.xsd`
//const xml_path = "D:\\Sorgenti\\PELL_WS\\data\\PELL_GENOVA_v780_3_rev01.xml"
const xml_path = `${cwd}\\data\\PELL_xml_NeMeA_validato.xml`
const sch_path = `${cwd}\\data\\CensusTechSheetRequirements.sch`

function validate_xml_xsd(req, res, next) {
	try{
		//console.log(arguments);
	  validator.validateXML({ file: xml_path }, xsd_path, function(err, result) {
      if (err) {
        console.log(err);
        //res.status(500).send({error: err.message});
        next(err);
      }

      res.send({valid: result.valid});
    });

	} catch (err){
			console.log(err);			
	}	
}

function validate_xml_sch(req, res, next) {
  sch_validator.validate(xml_path, sch_path, function(err, result){
    if (err){
      console.log(err);
      next (err);
    }
    res.send({valid: result.valid});
  });
	//res.send({todo: "TODO!"});
}


module.exports = {
  validate_xml_xsd,
  validate_xml_sch
}