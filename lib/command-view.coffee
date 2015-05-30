{View,TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

module.exports =
class CommandView extends View
  nameEditor: null
  commandEditor: null
  wdEditor: null

  @content: ->
    @div class: 'commandview', =>
      @div class:'block', =>
        @label =>
          @div class:'settings-name', 'Command Name'
          @div =>
            @span class:'inline-block text-subtle', 'Name of command when using '
            @span class:'inline-block highlight', 'build-tools-cpp:show-commands'
        @subview 'command_name', new TextEditorView(mini:true)
      @div class:'block', =>
        @label =>
          @div class:'settings-name', 'Command'
          @div =>
            @span class:'inline-block text-subtle', 'Command to execute '
        @subview 'command_text', new TextEditorView(mini:true)
      @div class:'block', =>
        @label =>
          @div class:'settings-name', 'Working Directory'
          @div =>
            @span class:'inline-block text-subtle', 'Directory to execute command in'
        @subview 'working_directory', new TextEditorView(mini:true, placeholderText: '.')
      @div class:'block checkbox', =>
        @input id:'command_in_shell', type:'checkbox'
        @label =>
          @div class:'settings-name', 'Execute in shell'
          @div =>
            @span class:'inline-block text-subtle', 'Execute the command in your OS\'s shell. Change "Shell Command" in build-tools-cpp\'s settings if you are not using bash or use windows'
      @div class:'streams', =>
        @div class:'stream', id:'stdout', =>
          @div class:'small-header', 'stdout'
          @div class:'block checkbox', =>
            @input id:'mark_paths_stdout', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Mark file paths + coordinates'
              @div =>
                @span class:'inline-block text-subtle', 'Allows you to click on file paths'
          @div class:'block', =>
            @label =>
              @div class:'settings-name', 'Highlighting'
              @div =>
                @span class:'inline-block text-subtle', 'How to highlight this stream'
            @div id:'stdout', class:'btn-group btn-group-sm', outlet:'stdout_highlights', =>
              @button id:'nh', class:'btn selected', 'No highlighting'
              @button id:'ha', class:'btn', 'Highlight all'
              @button id:'ht', class:'btn', 'Only lines with error or warning tags'
              @button id:'hc', class:'btn', 'GCC/Clang-like highlighting'
          @div class:'block checkbox hidden', outlet:'stdout_lint', =>
            @input id:'lint_stdout', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Lint errors/warnings'
              @div =>
                @span class:'inline-block text-subtle', 'Use Linter package to highlight errors in your code'
        @div class:'stream', id:'stderr', =>
          @div class:'small-header', 'stderr'
          @div class:'block checkbox', =>
            @input id:'mark_paths_stderr', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Mark file paths + coordinates'
              @div =>
                @span class:'inline-block text-subtle', 'Allows you to click on file paths'
          @div class:'block', =>
            @label =>
              @div class:'settings-name', 'Highlighting'
              @div =>
                @span class:'inline-block text-subtle', 'How to highlight this stream'
            @div id:'stderr', class:'btn-group btn-group-sm', outlet:'stderr_highlights', =>
              @button id:'nh', class:'btn selected', 'No highlighting'
              @button id:'ha', class:'btn', 'Highlight all'
              @button id:'ht', class:'btn', 'Only lines with error or warning tags'
              @button id:'hc', class:'btn', 'GCC/Clang-like highlighting'
          @div class:'block checkbox hidden', outlet:'stderr_lint', =>
            @input id:'lint_stderr', type:'checkbox'
            @label =>
              @div class:'settings-name', 'Lint errors/warnings'
              @div =>
                @span class:'inline-block text-subtle', 'Use Linter package to highlight errors in your code'

  initialize: (@callback) ->
    @disposables = new CompositeDisposable
    @nameEditor = @command_name.getModel()
    @commandEditor = @command_text.getModel()
    @wdEditor = @working_directory.getModel()

    @on 'click', '.btn', (e) =>
      if e.currentTarget.parentNode.id is 'stdout'
        @stdout_highlighting = e.currentTarget.id
        @stdout_highlights.find('.selected').removeClass('selected')
        e.currentTarget.classList.add('selected')
        if /ht|hc/.test(@stdout_highlighting)
          @stdout_lint.removeClass('hidden')
        else
          @stdout_lint.addClass('hidden')
      else if e.currentTarget.parentNode.id is 'stderr'
        @stderr_highlighting = e.currentTarget.id
        @stderr_highlights.find('.selected').removeClass('selected')
        e.currentTarget.classList.add('selected')
        if /ht|hc/.test(@stderr_highlighting)
          @stderr_lint.removeClass('hidden')
        else
          @stderr_lint.addClass('hidden')

    @disposables.add atom.commands.add @element, 'core:confirm': (event) =>
        if ((n=@nameEditor.getText()) isnt '') and ((c=@commandEditor.getText()) isnt '')
          @callback(@oldname, {
            name: n,
            command: @commandEditor.getText(),
            wd: if (d=@wdEditor.getText()) is '' then '.' else d,
            shell: @find('#command_in_shell').prop('checked')
            stdout: {
              file: @find('#mark_paths_stdout').prop('checked')
              highlighting: @stdout_highlighting
              lint: if @stdout_lint.hasClass('hidden') then false else @find('#lint_stdout').prop('checked')
            }
            stderr: {
              file: @find('#mark_paths_stderr').prop('checked')
              highlighting: @stderr_highlighting
              lint: if @stderr_lint.hasClass('hidden') then false else @find('#lint_stderr').prop('checked')
            }
            })
          @hide()
        event.stopPropagation()

    @disposables.add atom.commands.add @element, 'core:cancel': (event) =>
        @hide()
        event.stopPropagation()

  destroy: ->
    @disposables.dispose()
    @detach()

  hide: ->
    @panel?.hide()

  visible: ->
    @panel?.isVisible()

  show: (items) ->
    @nameEditor.setText("")
    @commandEditor.setText("")
    @wdEditor.setText("")

    @find('#command_in_shell').prop('checked', false)
    @find('#mark_paths_stdout').prop('checked', true)
    @find('#mark_paths_stderr').prop('checked', true)
    @find('#lint_stdout').prop('checked', false)
    @find('#lint_stderr').prop('checked', false)

    @stdout_highlights.find('.selected').removeClass('selected')
    @stderr_highlights.find('.selected').removeClass('selected')
    @stdout_highlights.find('#nh').addClass('selected')
    @stderr_highlights.find('#nh').addClass('selected')

    @stdout_highlighting = 'nh'
    @stderr_highlighting = 'nh'
    @oldname = null
    if items?
      @oldname = items.name
      @nameEditor.setText(items.name)
      @commandEditor.setText(items.command)
      @wdEditor.setText(items.wd)
      @find('#command_in_shell').prop('checked', items.shell)
      @find('#mark_paths_stdout').prop('checked', items.stdout.file)
      @find('#mark_paths_stderr').prop('checked', items.stderr.file)
      @stdout_highlights.find('.selected').removeClass('selected')
      @stderr_highlights.find('.selected').removeClass('selected')
      @stdout_highlights.find("\##{items.stdout.highlighting}").addClass('selected')
      @stderr_highlights.find("\##{items.stderr.highlighting}").addClass('selected')
      @stdout_highlighting = items.stdout.highlighting
      @stderr_highlighting = items.stderr.highlighting
      @stdout_lint.find('#lint_stdout').prop('checked', items.stdout.lint)
      @stderr_lint.find('#lint_stderr').prop('checked', items.stderr.lint)
      if /ht|hc/.test(@stdout_highlighting)
        @stdout_lint.removeClass('hidden')
      else
        @stdout_lint.addClass('hidden')
      if /ht|hc/.test(@stderr_highlighting)
        @stderr_lint.removeClass('hidden')
      else
        @stderr_lint.addClass('hidden')

    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    @command_name.focus();
