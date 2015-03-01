require 'ruble'

@@COUNT = 1

command 'Getter/Setter generator' do |cmd|
  cmd.scope = 'source.php'
  cmd.output = :insert_as_snippet
  cmd.input = :document
  cmd.key_binding = "Ctrl+G"
  cmd.invoke do |context|
    vars     = get_vars
    contents = context.input
    props     = []
    type = nil
    vars.each { |var|
      if var.match(/@var\s+([^\s]+)/)
          type = $1
      end
      if var.match(/(?:protected|private)\s*\$(\w+)\s*(.)*;/)
        props.push(get_both($1, type, contents))
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
    type = nil
    vars.each { |var|
      if var.match(/@var\s+([^\s]+)/)
          type = $1
      end
      if var.match(/(?:protected|private)\s*\$(\w+);/)
        props.push(get_getter($1, type, contents))
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
    type = nil
    vars.each { |var|
      if var.match(/@var\s+([^\s]+)/)
          type = $1
      end
      if var.match(/(?:protected|private)\s*\$(\w+);/)
        props.push(get_setter($1, type, contents))
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

def get_getter(name, type, contents)
  getter = 'get' + name.slice(0,1).capitalize + name.slice(1..-1)
  if contents.match(/function #{getter}/)
    return
  end

  if type
    paramType = type
  else
    paramType = '${' + @@COUNT.to_s + ':VariableType}'
  end

    '/**
     * Get ' + name + '
     *
     * @return ' + paramType + '
     */
    public function ' + getter + '()
    {
        return \$this->' + name + ';
    }'
end

def get_setter(name, type, contents)

  setter = 'set' + name.slice(0,1).capitalize + name.slice(1..-1)

  if contents.match(/function #{setter}/)
    return
  end

  if type
    paramType = type
    if type == 'string'
      paramCast = ''
      paramPrototype = ''
    else
      if type.match(/int|bool/)
        paramCast = '(' + type + ') '
        paramPrototype = ''
      else
        paramCast = ''
        paramPrototype = type + ' '
      end
    end
  else
    paramType = '${' + @@COUNT.to_s + ':VariableType}'
    paramCast = ''
    paramPrototype = ''
  end

    '/**
     * Set ' + name + '
     *
     * @param ' + paramType + ' \$' + name + '
     * @return ' + get_fqn(contents).to_s.split(" ")[0] + '
     */
    public function ' + setter + '(' + paramPrototype + '\$' + name + ')
    {
        \$this->' + name + ' = ' + paramCast + '\$' + name + ';
        return \$this;
    }'
end

def get_both(name, type, contents)
  out = "\t" + get_setter(name, type, contents).to_s
  out += "\n\n"
  out += "\t" + get_getter(name, type, contents).to_s

  @@COUNT += 1

  return out.strip
end

def get_fqn(contents)
  fqn = nil
  ns  = nil
  cls = nil

  if contents.match(/namespace (.*);/)
    ns = '\\' + $1
  end

  if contents.match(/class (.*)/)
    cls = $1
  end

  ns.nil? ? cls : ns + '\\' + cls
end