$(function(){
  var Chatbot = {
    $form: $("form"),
    $input: $("form input"),
    $response: $('.response'),
    $reply: $('.response .reply'),
    $retrain: $(".response .re-train"),
    data: {},

    submitForm: function() {
      Chatbot.$response.addClass("-hidden");
      Chatbot.$retrain.addClass("-hidden");

      query = Chatbot.$input.val().replace(/[^0-9a-z ,.]/gi, '');

      $.ajax({
        method: "post",
        url: "/",
        data: { query: query }
      })
      .done(function(resp) {
        Chatbot.data = JSON.parse(resp);

        Chatbot.$input.val("");
        Chatbot.$reply.html(Chatbot.data.response);

        Chatbot.$response.removeClass("-hidden");

        if (Chatbot.data.category === "uncategorised") {
          Chatbot.$retrain.removeClass("-hidden");
        }
      });
    },

    showReTrain: function() {
      Chatbot.$retrain.removeClass("-hidden");
    },

    reTrain: function(category) {
      Chatbot.$response.addClass("-hidden");
      Chatbot.$retrain.addClass("-hidden");
      $.ajax({
        method: "post",
        url: "/train",
        data: {
          query: Chatbot.data.query,
          category: category
        }
      })
      .done(function(resp) {
        console.log("swaz", JSON.parse(resp));
      });
    }
  };

  $(document).on("submit", "form", function(ev) {
    ev.preventDefault();
    Chatbot.submitForm();
  });

  $(document).on("click", ".bad-response", function(ev) {
    ev.preventDefault();
    Chatbot.showReTrain();
  });

  $(document).on("click", ".re-train a", function(ev) {
    ev.preventDefault();
    Chatbot.reTrain($(ev.currentTarget).attr("data-category"));
  });
});