(defproject whiteboard "0.1.0"
  :description "Drawing with HTML5"
  :url "https://github.com/concordusapps/whiteboard"
  :license {:name "MIT"
            :url "http://opensource.org/licenses/MIT"}
  :dependencies [[org.clojure/clojure "1.6.0"]
                 [org.clojure/clojurescript "0.0-2268"]
                 [om "0.6.4"]]
  :plugins [[lein-cljsbuild "1.0.3"]]
  :cljsbuild {
    :builds [{:id "whiteboard"
              :source-paths ["src/scripts"]
              :compiler {
                :output-to "temp/scripts/whiteboard.js"
                :output-dir "temp/out"
                :optimizations :none
                :source-map true}}]})
