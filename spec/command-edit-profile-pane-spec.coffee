CommandEditProfilePane = require '../lib/view/command-edit-profile-pane'

{$} = require 'atom-space-pen-views'

describe 'Command Edit Profile Pane', ->
  view = null

  beforeEach ->
    view = new CommandEditProfilePane
    jasmine.attachToDOM(view.element)

  afterEach ->
    view.destroy?()

  it 'has a pane', ->
    expect(view.element).toBeDefined()

  describe 'On set with a value', ->

    beforeEach ->
      view.set {
        stdout:
          pty: true
          highlighting: 'nh'
          ansi_option: 'parse'
        stderr:
          highlighting: 'hc'
          profile: 'python'
      }

    it 'sets the fields accordingly', ->
      expect(view.stderr_div.hasClass('hidden')).toBe true
      expect(view.find('#pty').prop('checked')).toBe true
      expect(view.stdout_highlights.find('.selected')[0].id).toBe 'nh'
      expect(view.stderr_highlights.find('.selected')[0].id).toBe 'hc'
      expect(view.stdout_ansi_div.hasClass('hidden')).toBe false
      expect(view.stderr_ansi_div.hasClass('hidden')).toBe true
      expect(view.stdout_profile_div.hasClass('hidden')).toBe true
      expect(view.stderr_profile_div.hasClass('hidden')).toBe false
      expect(view.stdout_regex_div.hasClass('hidden')).toBe true
      expect(view.stderr_regex_div.hasClass('hidden')).toBe true
      expect(view.stderr_profile.children()[view.stderr_profile[0].selectedIndex].attributes.getNamedItem('value').nodeValue).toBe 'python'

  describe 'On set without a value', ->

    beforeEach ->
      view.set()

    it 'sets the fields to their default values', ->
      expect(view.stderr_div.hasClass('hidden')).toBe false
      expect(view.find('#pty').prop('checked')).toBe false
      expect(view.stdout_highlights.find('.selected')[0].id).toBe 'nh'
      expect(view.stderr_highlights.find('.selected')[0].id).toBe 'nh'
      expect(view.stdout_ansi.find('.selected')[0].id).toBe 'ignore'
      expect(view.stderr_ansi.find('.selected')[0].id).toBe 'ignore'
      expect(view.stdout_profile_div.hasClass('hidden')).toBe true
      expect(view.stderr_profile_div.hasClass('hidden')).toBe true

  describe 'On get', ->
    c = {}
    r = null

    beforeEach ->
      view.set()
      view.find('#pty').click()
      view.stdout_highlights.find('#nh').click()
      view.stderr_highlights.find('#hc').click()
      view.stdout_ansi.find('#remove').click()
      r = view.get c

    it 'returns null', ->
      expect(r).toBe null

    it 'updates the command', ->
      expect(c).toEqual {
        stdout:
          pty: true
          pty_rows: 25
          pty_cols: 80
          highlighting: 'nh'
          profile: undefined
          ansi_option: 'remove'
        stderr:
          highlighting: 'hc'
          profile: 'gcc_clang'
      }
