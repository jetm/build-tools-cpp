Profile = require './profile'
XRegExp = require('xregexp').XRegExp

module.exports =
  class Java extends Profile
    @profile_name: 'Java'

    scopes: ['source.java']

    regex_string: '
    (?<file> [\\S]+\\.(?extensions)): #File \n
    (?<row> [\\d]+)? #Row \n
    :\\s(?<type> error): \n
    [\\s]* (?<message> [\\S\\s]+) #Type and Message \n
    '

    file_string: '
    (?<file> [\\S]+\\.(?extensions)): #File \n
    (?<row> [\\d]+)? #Row\n
    '

    constructor: (output) ->
      super(output)
      @regex = @createRegex @regex_string
      @regex_file = @createRegex @file_string

    files: (line) ->
      start = 0
      out = []
      while (m = XRegExp.exec line.substr(start), @regex_file)?
        start += m.index
        m.start = start
        m.end = start + m.file.length + (if m.row? then m.row.length else 0)
        m.row = '0' if not m.row?
        m.col = '0'
        start = m.end + 1
        out.push m
      out

    in: (line) ->
      if (m = XRegExp.exec line, @regex)? #Start of error message
        @status = m.type
        @indentation= line.indexOf(m.file)
        @output.print m
        @lint m
      else if @indentation? and line.slice(@indentation)[0] isnt ' ' #End of error message
        @output.print input: line
        @status = null
        @indentation = null
      else if @status? #Inside error message
        @output.print input: line, type: @status
      else #Rest
        @output.print input: line

    clear: ->
      @status = null
      @indentation = null