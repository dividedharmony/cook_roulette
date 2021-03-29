(function ($) {
  $(document).ready(function() {
    if ($("#recipe-show").length > 0) {
      setupRecipeShow();
    }
  })

  function setupRecipeShow() {
    $.ajax(
      "/ingredients.json"
    ).done(function(payload_string) {
      var payload = JSON.parse(payload_string);
      insertIngredients(payload);
    }).fail(function (error_msg) {
      console.warn(error_msg);
    });

    $(".ingredient-form").each(function(_f_index, form) {
      var $form = $(form);
      var $newIngredientType = $($form.find(".new-ingredient-type"));
      var $newIngredientField = $($form.find(".new-ingredient-field"));
      var $oldIngredientType = $($form.find(".old-ingredient-type"));
      var $oldIngredientField = $($form.find(".old-ingredient-field"));
      var $submit = $($form.find(".submit-ingredient"));

      $newIngredientType.on("change", ingredientSourceListener(
        $newIngredientType,
        $newIngredientField,
        $oldIngredientField
      ));

      $oldIngredientType.on("change", ingredientSourceListener(
        $oldIngredientType,
        $oldIngredientField,
        $newIngredientField
      ));

      $form.find(".ingredient-selector").each(function (_i_index, ingredientInput) {
        var $input = $(ingredientInput);
        $input.on("change", toggleSubmitListener($input, $submit));
        $input.on("blur", toggleSubmitListener($input, $submit));
      });
    });

    function insertIngredients(ings) {
      var ingredients = ings || [];
      var options = []
      for (var i = 0; i < ingredients.length; i++) {
        var ingredient = ingredients[i]["ingredient"];
        var option = '<option value="' + ingredient["id"] + '">' + ingredient["name"] + '</option>'
        options.push(option);
      }
      var $selectIngredients = $(".existing-ingredients");
      $selectIngredients.each(function () {
        var $select = $(this);
        $select.append(options);
      });
    }

    function ingredientSourceListener($sourceType, $sourceFieldset, $oppositeField) {
      var onChange = function () {
        var isSource = $sourceType.is(":checked");
        if (isSource) {
          $sourceFieldset.show();
          var $oppostieInput = $($oppositeField.find(".ingredient-selector"));
          $oppositeField.hide();
          $oppostieInput.val(null);
        } else {
          $sourceFieldset.hide();
        }
      };

      // evoke on change for initial setup
      onChange();
      return onChange;
    }

    function toggleSubmitListener($input, $submit) {
      return function () {
        var inputValue = $input.val();
        if (!!inputValue) {
          $submit.show();
        } else {
          $submit.hide();
        }
      };
    }
  }
})(window.jQuery);
