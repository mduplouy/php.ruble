require 'ruble'

command 'Activate PHPDoc' do |cmd|
  cmd.key_binding = 'CONTROL+SHIFT+COMMAND+W'
  cmd.output = :insert_as_snippet
  cmd.input = :selection
  cmd.invoke do |context|
    input = STDIN.read
    signature = input.scan(/\(([^\)]+)/)[0][0];
    methodName = input.scan(/function ([^\(]+)/)[0][0]
    methodNameArray = methodName.strip().split("_");
    methodDescription = "";
    methodNameArray.each do |namePart|
      methodDescription += namePart.capitalize + " ";
    end
    methodDescription = methodDescription.strip() + "\n";
    signatureStringSplit = signature.split(',');
    toPrint = "\t/**\n";
    toPrint += "\t * " + "${1:" + methodDescription + "} \n"
    signatureStringSplit.each do |myVar|
            myVar = myVar.strip().gsub!('$', '\$')
            varType = (myVar =~ /id$/) ? "integer" : "string"
            toPrint += "\t * @param " + varType + " " + myVar + "\n";
    end
    if /\breturn\b/.match(input) 
      toPrint += "\t * @return ${3:Variable Type}\n";
    end
    toPrint += "\t */\n"
    toPrint += input.gsub!('$', '\$')
    print toPrint

  end
end
