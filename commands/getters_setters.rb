require 'ruble'

@@COUNT = 1

command 'Getter/Setter generator' do |cmd|
  cmd.scope = 'source.php'
  cmd.output = :insert_as_snippet
  cmd.input = :document
  cmd.key_binding = "Ctrl+S"
  cmd.invoke do |context|
    vars     = get_vars
    contents = context.input
    props     = []
    vars.each { |var|
      if var.match(/(?:public|protected|private)\s*\$(\w+)(.)*;/)
        props.push(get_both($1, contents))
      end
    }

    print_content(context.input, props)
  end
end

command 'Getter generator' do |cmd|
  cmd.scope = 'source.php'
  cmd.output = :insert_as_snippet
  cmd.input = :document
  cmd.key_binding = "M2+M3+G"
  cmd.invoke do |context|
    vars     = get_vars
    contents = context.input
    props     = []
    vars.each { |var|
      if var.match(/(?:public|protected|private)\s*\$(\w+);/)
        props.push(get_getter($1, contents))
      end
    }

    print_content(context.input, props)
  end
end

command 'Setter generator' do |cmd|
  cmd.scope = 'source.php'
  cmd.output = :insert_as_snippet
  cmd.input = :document
  cmd.key_binding = "M2+M3+S"
  cmd.invoke do |context|
    vars     = get_vars
    contents = context.input
    props     = []
    vars.each { |var|
      if var.match(/(?:public|protected|private)\s*\$(\w+);/)
        props.push(get_setter($1, contents))
      end
    }

    print_content(context.input, props)
  end
end

def print_content(contents, props)
    last = contents.rindex(/}/)
    contents[last] = ''
    contents.gsub!('$', '\$')
    contents += "\n\t" + props.join("\n\n\t") + "\n}"
    
    print contents
end

def get_vars
  vars = ENV['TM_SELECTED_TEXT'].nil? ? ENV['TM_CURRENT_LINE'] : ENV['TM_SELECTED_TEXT']
  vars.split("\n")
end

def get_getter(name, contents)
  getter = 'get_' + name
  if contents.match(/#{getter}/)
    return
  end
  
    '/**
     * Get ' + name + '
     *
     * @return ${' + @@COUNT.to_s + ':VariableType}
     */
    public function ' + getter + '()
    {
        return \$this->' + name + ';
    }'
end

def get_setter(name, contents)
  setter = 'set_' + name
  
  if contents.match(/#{setter}/)
    return
  end
    
    '/**
     * Set ' + name + '
     *
     * @param ${' + @@COUNT.to_s + ':VariableType} \$' + name + '
     * @return ' + get_fqn(contents).to_s.split(" ")[0] + '
     */
    public function ' + setter + '(\$' + name + ')
    {
        \$this->' + name + ' = \$' + name + ';
        return \$this;
    }'
end

def get_both(name, contents)
  out = "\t" + get_getter(name, contents).to_s
  out += "\n\n"
  out += "\t" + get_setter(name, contents).to_s
  
  @@COUNT += 1
  
  return out.strip
end

def get_fqn(contents)
  fqn = nil
  ns  = nil
  cls = nil
    
  if contents.match(/namespace (.*);/)
    ns = $1
  end
    
  if contents.match(/class (.*)/)
    cls = $1
  end
    
  ns.nil? ? cls : ns + '\\' + cls
end