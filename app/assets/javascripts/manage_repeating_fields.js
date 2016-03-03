// This widget manages the adding and removing of repeating fields.
// There are a lot of assumptions about the structure of the classes and elements.
// These assumptions are reflected in the MultiValueInput class.

var HydraEditor = (function($) {
      var FieldManager = function (element, options) {
          this.element = $(element);
          this.options = options;

          this.controls = $("<span class=\"input-group-btn field-controls\">");
          this.remover  = $("<button type=\"button\" class=\"btn btn-danger remove\"><i class=\"icon-white glyphicon-minus\"></i><span>Remove</span></button>");
          this.adder    = $("<button type=\"button\" class=\"btn btn-success add\"><i class=\"icon-white glyphicon-plus\"></i><span>Add</span></button>");

          this.fieldWrapperClass = '.field-wrapper';
          this.warningClass = '.has-warning';
          this.listClass = '.listing';

          this.init();
      }

      FieldManager.prototype = {
          init: function () {
              this._addInitialClasses();
              this._appendControls();
              this._attachEvents();
              this._addCallbacks();
          },

          _addInitialClasses: function () {
              this.element.addClass("managed");
              $(this.fieldWrapperClass, this.element).addClass("input-group input-append");
          },

          _appendControls: function() {
              $(this.fieldWrapperClass, this.element).append(this.controls);
              $(this.fieldWrapperClass+':not(:last-child) .field-controls', this.element).append(this.remover);
              $('.field-controls:last', this.element).append(this.adder);
          },

          _attachEvents: function() {
              var _this = this;
              this.element.on('click', '.remove', function (e) {
                _this.removeFromList(e);
              });
              this.element.on('click', '.add', function (e) {
                _this.addToList(e);
              });
          },

          _addCallbacks: function() {
              this.element.bind('managed_field:add', this.options.add);
              this.element.bind('managed_field:remove', this.options.remove);
          },

          addToList: function( event ) {
            event.preventDefault();
            var $activeField = $(event.target).parents(this.fieldWrapperClass)

            if (this.inputIsEmpty($activeField)) {
                this.displayEmptyWarning();
            } else {
                var $listing = $(this.listClass, this.element);
                this.clearEmptyWarning();
                $listing.append(this._newField($activeField));
            }
          },

          inputIsEmpty: function($activeField) {
              return $activeField.children('input.multi-text-field').val() === '';
          },

          _newField: function ($activeField) {
              var $newField = this.createNewField($activeField);
              // _changeControlsToRemove must come after createNewField
              // or the new field will not have an add button
              this._changeControlsToRemove($activeField);
              return $newField;
          },

          createNewField: function($activeField) {
              $newField = $activeField.clone();
              $newField = this._cleanButtons($newField);
              $newField.children('.field-controls').append(this.remover.clone());
              $newChildren = $newField.children('input');
              $newChildren.val('').removeProp('required');
              $newChildren.first().focus();
              this.element.trigger("managed_field:add", $newChildren.first());
              return $newField
          },

          _changeControlsToRemove: function($activeField) {
              var $removeControl = this.remover.clone();
              $activeField = this._cleanButtons($activeField);
              $activeFieldControls = $activeField.children('.field-controls');
              $('.add', $activeFieldControls).remove();
              $activeFieldControls.prepend($removeControl);
          },

          _cleanButtons: function($newField) {
              $('.remove', $newField.children('.field-controls')).remove();
              return $newField
          },

          clearEmptyWarning: function() {
              $listing = $(this.listClass, this.element),
              $listing.children(this.warningClass).remove();
          },

          displayEmptyWarning: function () {
              $listing = $(this.listClass, this.element)
              var $warningMessage  = $("<div class=\'message has-warning\'>cannot add new empty field</div>");
              $listing.children(this.warningClass).remove();
              $listing.append($warningMessage);
          },

          removeFromList: function( event ) {
            event.preventDefault();

            var field = $(event.target).parents(this.fieldWrapperClass)
            var secondLast = field.parents('.listing').children('.input-group:nth-last-child(2)');
            var addCount = field.children('.field-controls').children('.add').length;

            field.remove();

            if(addCount > 0){
              secondLast.children('.field-controls').prepend(this.adder);
            }

            this.element.trigger("managed_field:remove", field);
          },

          destroy: function() {
            $(this.fieldWrapperClass, this.element).removeClass("input-append");
            this.element.removeClass( "managed" );
          }
      }

      FieldManager.DEFAULTS = {
          add: null,
          remove: null
      }

      return { FieldManager: FieldManager };
})(jQuery);

(function($){
    $.fn.manage_fields = function(option) {
        return this.each(function() {
            var $this = $(this);
            var data  = $this.data('manage_fields');
            var options = $.extend({}, HydraEditor.FieldManager.DEFAULTS, $this.data(), typeof option == 'object' && option);

            if (!data) $this.data('manage_fields', (data = new HydraEditor.FieldManager(this, options)));
        })
    }
})(jQuery);
