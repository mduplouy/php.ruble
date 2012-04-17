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
    if methodNameArray.count == 1
      methodNameArray = methodName.split /(?=[A-Z])/
      methodDescription = ""
      methodNameArray.each do |namePart|
        methodDescription += namePart.capitalize + " "
      end
      methodDescription.strip()
    end
    methodDescription = methodDescription.strip()
    signatureStringSplit = signature.split(',');
    toPrint = "\t/**\n";
    toPrint += "\t * " + "${" + @@COUNT.to_s + ":" + methodDescription + "}\n"
    @@COUNT += 1
    toPrint += "\t *\n"
    if signatureStringSplit.count > 0
      signatureStringSplit.each do |myVar|
        myVarArray = myVar.split("=");
        
        myVar = myVarArray[0].strip()
        myVar = myVar.gsub!('$', '\$')
        varType = ""

        if myVarArray[1]
          varType = get_var_type(myVarArray[1])
        end
        if varType == ""
          varType = get_var_type(myVar)
        end
        if myVar.include? " "
          myVarArray = myVar.split(' ')
          myVar = myVarArray[1]
          varType = myVarArray[0]
        end
        toPrint += "\t * @param ${" + @@COUNT.to_s + ":" + varType + "} " + myVar + "\n";
        @@COUNT += 1
      end
    end

    if /\breturn\b/.match(input)
      returnType = get_var_type("", methodNameArray)
      toPrint += "\t * @return ${" + @@COUNT.to_s + ":" + returnType + "}\n"
      @@COUNT += 1
    end
    toPrint += "\t */\n"
    toPrint += input.gsub!('$', '\$')
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
    varType = get_var_type(variableName)
    toPrint += "\t * @var ${" + @@COUNT.to_s + ":" + varType + "}\n"
    @@COUNT += 1

    toPrint += "\t */\n"
    toPrint += input.gsub!('$', '\$')
    print toPrint
  end
end

def get_var_type(var, methodNameArray = Array.new)
  methodNameArray.each do |methodNamePart|
    case methodNamePart.downcase
    when "is", "can", "has"
      return "boolean"
    when "count", "total"
      return "integer"
    when "ids"
       return "array"
    end
  end
  var = var.strip()
  if var == "true" || var == "false"
    varType = "boolean"
  elsif (var =~ /id$/i || var =~ /^[0-9]+$/)
    varType = "integer"
  elsif (var =~ /array/i)
    varType = "array"
  else
    varType = "string"
  end
  return varType
end