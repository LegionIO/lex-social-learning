# frozen_string_literal: true

require 'legion/extensions/social_learning/version'
require 'legion/extensions/social_learning/helpers/constants'
require 'legion/extensions/social_learning/helpers/observed_behavior'
require 'legion/extensions/social_learning/helpers/model_agent'
require 'legion/extensions/social_learning/helpers/social_learning_engine'
require 'legion/extensions/social_learning/runners/social_learning'
require 'legion/extensions/social_learning/client'

module Legion
  module Extensions
    module SocialLearning
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
