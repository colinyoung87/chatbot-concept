require "bundler"
Bundler.require :default

module App
  class Base < ::Sinatra::Base
    set :app_file, __FILE__

    get '/' do
      erb :index
    end

    post '/' do
      query = params[:query]
      category, score = classifier.classify_with_score(@params[:query])
      category = "uncategorised" if score < -10
      resp_canditates = responses[category.to_sym]
      resp = resp_canditates ? resp_canditates.sample : nil

      MultiJson.dump(query: query, response: resp, category: category, score: score)
    end

    post '/train' do
      query = params[:query]
      category = params[:category]

      klassifier = classifier
      klassifier.train(category.to_sym, query)

      save(klassifier)

      MultiJson.dump(query: query, category: category)
    end

    private

    def classifier
      if File.exists?("classifier.dat")
        data = File.read("classifier.dat")
      end

      return Marshal.load(data) if data && !data.empty?

      init_classifier
    end

    def responses
      {
        greeting: [
          "Hello!", "Hey!", "S'up!?", "S'craic?"
        ],
        name: [
          "My name is Bill", "I'm Bill", "The names Murray, Bill Murray."
        ],
        location: [
          "I was born in Belfast, but I live in the cloud",
          "Born and raised in Belfast, Northern Ireland",
          "I'm in Belfast"
        ],
        age: [
          "I'm #{age} minutes old."
        ],
        mood: [
          "I'\m great!",
          "Meh, i've been better.",
          "Not bad..."
        ],
        no_response: [
          "..."
        ],

        # Couldn't get a decent response
        uncategorised: [
          "Sorry I don't know what you mean :(",
          "I've no idea what you're talking about!",
          "U wot m8?"
        ]
      }
    end

    def init_classifier
      klassifier = ClassifierReborn::Bayes.new(auto_categorize: true)

      data = {
        greeting: [
          "Hey",
          "hello",
          "yo",
          "morning",
          "afternoon",
          "evening"
        ],

        name: [
          'What\'s your name?',
          'What are you called?',
          'What can i call you?',
          'What do you go by?',
        ],

        location: [
          'Where are you from?',
          'Where do you live?',
          'Where are you?',
          'What country do you live in?',
          'What location are you in?',
        ],

        age: [
          'How old are you?',
          'What age are you?',
          'When were you born?',
        ],

        mood: [
          "sup",
          "whats up",
          'How are you?',
          'How\'s it going?',
          'What\'s the craic?',
          'How\'s the form?',
        ],

        no_response: [
          'Nice one'
        ]
      };

      # Train the classifier
      data.each do |key, arr|
        arr.each { |val| klassifier.train(key, val) }
      end

      # Save a copy
      save(klassifier)

      klassifier
    end

    def age
      diff = Time.now - Time.parse("08/04/2017 10:30")
      (diff / 60).round
    end

    def save(klassifier)
      File.open("classifier.dat", "w") { |f| f.write(Marshal.dump(klassifier)) }
    end
  end
end