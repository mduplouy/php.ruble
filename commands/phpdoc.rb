require 'ruble'

@@COUNT = 1

command 'Add PHPDoc For Method/Function' do |cmd|
  cmd.key_binding = 'CONTROL+SHIFT+COMMAND+C'
  cmd.output = :insert_as_snippet
  cmd.input = :selection
  cmd.invoke do |context|
    input = STDIN.read
    signature = input.scan(/function [a-zA-Z0-9_]+[ ]?\(([^\)]*)/i)[0][0]
    methodName = input.scan(/function ([^\(]+)/)[0][0]
    methodNameArray = methodName.strip().split("_")
    methodDescription = ""
    methodNameArray.each do |namePart|
      methodDescription += namePart.capitalize + " "
    end
    methodDescription = methodDescription.strip()
    signatureStringSplit = signature.split(',');
    toPrint = "\t/**\n";
    toPrint += "\t * " + "${" + @@COUNT.to_s + ":" + methodDescription + "}\n"
    @@COUNT += 1
    toPrint += "\t *\n"
    CONSOLE.puts signatureStringSplit.count
    CONSOLE.puts signatureStringSplit.inspect
    if signatureStringSplit.count > 0
      signatureStringSplit.each do |myVar|
        CONSOLE.puts "HERE"
        myVar = myVar.strip().gsub!('$', '\$')
        varType = (myVar =~ /id$/) ? "integer" : "string"
        if myVar.include? " "
          myVarArray = myVar.split(' ')
          myVar = myVarArray[1]
          varType = myVarArray[0]
        end
        toPrint += "\t * @param ${" + @@COUNT.to_s + ":" + varType + "} " + myVar + "\n";
        @@COUNT += 1
      end
    end

    CONSOLE.puts "AFTER"
    if /\breturn\b/.match(input) 
      toPrint += "\t * @return ${" + @@COUNT.to_s + ":string}\n"
      @@COUNT += 1
    end
    CONSOLE.puts toPrint
    toPrint += "\t */\n"
    CONSOLE.puts toPrint
    toPrint += input.gsub!('$', '\$')
    CONSOLE.puts toPrint
    print toPrint
  end
end

command 'Add PHPDoc For Class Variables' do |cmd|
  cmd.key_binding = 'CONTROL+SHIFT+COMMAND+C'
  cmd.output = :insert_as_snippet
  cmd.input = :selection
  cmd.invoke do |context|
    input = STDIN.read
    variableName = input.scan(/\$([^;]+)/)[0][0]
    variableNameArray = variableName.strip().split("_")
    variableDescription = ""
    variableNameArray.each do |namePart|
      variableDescription += namePart.capitalize + " "
    end
    variableDescription = variableDescription.strip()
    toPrint = "\n\t/**\n";
    toPrint += "\t * " + "${" + @@COUNT.to_s + ":" + variableDescription + "}\n"
    @@COUNT += 1
    variableName = variableName.strip()
    varType = (variableName =~ /id$/) ? "integer" : "string"
    toPrint += "\t * @var ${" + @@COUNT.to_s + ":" + varType + "}\n"
    @@COUNT += 1

    toPrint += "\t */\n"
    toPrint += input.gsub!('$', '\$')
    print toPrint
  end
end
