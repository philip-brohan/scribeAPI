DoneButton = require './done-button'

DateField = React.createClass
  displayName: 'DateField'

  render: ->
    <div>
      <div className="left">
        <div className="input-field active">
          <label>{@props.instruction}</label>
          <input
            ref="input0"
            type="date"
            data-task_key={@props.key}
            onChange={@handleChange}
            value={@props.val}
          />
        </div>
      </div>
      <div className="right">
        <DoneButton onClick={@commitAnnotation} />
      </div>
    </div>

module.exports = DateField
