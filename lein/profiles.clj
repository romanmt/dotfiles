{:user {:dependencies [[org.clojars.gjahad/debug-repl "0.3.3"]
                       [im.chit/vinyasa "0.1.8"]
                       [puppetlabs/tools.namespace "0.2.4.1"]]
        :plugins [[lein-midje "3.1.3"]]
        :injections [(require 'vinyasa.inject)
                     (require 'alex-and-georges.debug-repl)
                     (vinyasa.inject/inject 'clojure.core '>
                                            '[[clojure.repl doc source]
                                              [alex-and-georges.debug-repl debug-repl]
                                              [clojure.pprint pprint pp]])]}}
