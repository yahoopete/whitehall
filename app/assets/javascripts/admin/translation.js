// change element type
// from: http://stackoverflow.com/questions/8584098/how-to-change-an-element-type-using-jquery
(function($) {
  $.fn.changeElementType = function(newType) {
    var attrs = {};

    $.each(this[0].attributes, function(idx, attr) {
      attrs[attr.nodeName] = attr.nodeValue;
    });

    this.replaceWith(function() {
      return $("<" + newType + "/>", attrs).append($(this).contents());
    });
  }
})(jQuery);


(function ($) {
  var _enableTranslation = function() {
    $(this).each(function() {
      console.log("operating on", $(this));
      var inputs = {};
      var input = inputs["en-GB"] = $(this);
      var label = $("label[for=" + input.attr("id") +"]");

      var translation_controls = $("<span class='translation-controls'></span>");
      var en_gb_link = $("<a href='#' class='translation'>en-GB</a>");

      var current_attribute = $(this).attr("id").replace("edition_", "")

      translation_controls.append(en_gb_link);
      label.append(translation_controls);

      var showLocale = function() {
        var locale = $(this).text();
        console.log(inputs);
        for(other_locale in inputs) {
          console.log("hiding", other_locale, inputs[other_locale]);
          $(inputs[other_locale]).hide();
        }
        console.log("showing", locale, inputs[locale]);
        $(inputs[locale]).show();
      }

      en_gb_link.click(showLocale);

      var translations = $(".translations").find("." + current_attribute);
      console.log("translations", translations)
      translations.each(function(i, t) {
        var locale = $(t).find("[id$=locale]").val();
        var link = $("<a href='#' class='translation'>" + locale + "</a>");
        link.click(showLocale)
        translation_controls.append(link);
        var translation = $(t).find("[id$=translation]");
        var parent = translation.closest(".translation");
        if (translation.prop("tagName") != input.prop("tagName")) {
         console.log("changing element type from", translation.prop("tagName"), "to", input.prop("tagName"));
          var oldValue = translation.val();
          translation.changeElementType(input.prop("tagName"));
          translation = $(t).find("[id$=translation]");
          translation.val(oldValue);
        }
        inputs[locale] = translation;
        input.after(translation);
        parent.hide();
      })

      en_gb_link.click();
    })
  }

  $.fn.extend({
    enableTranslation: _enableTranslation
  });
})(jQuery);

jQuery(function($) {
  $(":input.translateable").enableTranslation();
})
