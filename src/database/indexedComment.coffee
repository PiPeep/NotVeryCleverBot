# Instead of storing an index of all comments, we only store a select number of
# comments meeting a certain set of criteria. It doesn't make sense to keep
# indexes of all the low scoring comments.

Sequelize = require "sequelize"

validators = require "./validators"
associations = require "./associations"
comment = require "./comment"
indexer = require "../transform/indexer"

exports.define = (sequelize) ->

    # Columns
    # -------

    name =
        type: Sequelize.STRING
        validate: validators.nameComment
        primaryKey: true

    body = Sequelize.TEXT

    # Class Methods
    # -------------

    partialFromJson = (json) ->
        name: json.name
        body: indexer.rewrite json.body

    createFromJson = (json, callback=( -> )) ->
        IndexedComment.create(partialFromJson json).done callback

    # Instance Methods
    # ----------------

    getComment = associations.getOne ( -> comment.Comment), -> where: {@name}

    # Define Model
    # ------------

    exports.IndexedComment = IndexedComment = sequelize.define "IndexedComment",
        {name, body},
        classMethods: {partialFromJson, createFromJson}
        instanceMethods: {getComment}
