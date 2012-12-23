imap = require 'imap'

config = require './config'

logErr = (err) ->
  console.log err

checkErr = (cb) ->
  (err, args...) ->
    if err?
      logErr(err)
    else
      cb(args...)
    

withConnection = (conn, cb) ->
  fn = () ->
    cb(conn)
  # Because conn.isConnected doesn't seem to get updated.
  # TODO: IMAP: fix conn.isConnected
  if conn._state.isConnected
    fn()
  else
    conn.connect checkErr(fn)

recvBox = (box) ->

recvBoxList = (boxes) ->
  doBoxes = (prefix, boxes) ->
    for box, properties of boxes
      path = "#{prefix}#{box}"
      withConnection conn, (conn) ->
        conn.openBox path, true, checkErr(recvBox)
      if properties.children?
        doBoxes "#{path}#{properties.delimiter}", properties.children
  doBoxes "", boxes

for account, config of config.accounts
  conn = new imap.ImapConnection config

  withConnection conn, (conn) ->
    # TODO: IMAP: first param cannot be null
    conn.getBoxes "", checkErr(recvBoxList)