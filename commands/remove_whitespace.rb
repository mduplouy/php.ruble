require 'ruble'

command 'Remove Trailing Whitespace' do |cmd|
  cmd.scope = 'source.php'
  cmd.output = :document
  cmd.trigger = :execution_listener, "org.eclipse.ui.file.save"
  cmd.input = :document
  cmd.key_binding = "CONTROL+SHIFT+COMMAND+C"
  cmd.invoke do |context|
    CONSOLE.puts "Running Remove Trailing Whitespace"
    myStartLine = context.editor.selection.start_line
    myOutput = ""
    contents = context.input
    context.editor.document.get.each do |line|
      line = line.gsub(/\s+$/, $/)
      myOutput += line
    end
    Ruble::Editor.active.document = myOutput
    if(context.editor.dirty?)
      context.editor.save!
    end
    Ruble::Editor.go_to(:line => myStartLine + 1)
  end
end