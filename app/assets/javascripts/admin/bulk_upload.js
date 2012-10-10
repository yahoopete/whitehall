(function($) {
  $(document).ready(function() {
    $('#fileupload').fileupload({
      dataType: 'json',
      done: function (e, data) {
        $.each(data.result, function (index, file) {
          $('<p/>').text(file.name).appendTo('#bulk-file-upload');
        });
      },
      add: function (e, data) {
          data.context = $('<p/>').text('Uploading...').appendTo('#bulk-file-upload');
      }
    });
  });
})(jQuery);
