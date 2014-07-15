(ns whiteboard.strokes
  (:require [om.core :as om :include-macros true]
            [om.dom :as dom :include-macros true]))

(defn Stroke [data owner]
  (reify
    om/IRender
    (render [this]
      (dom/li #js {:className "stroke-item"}
              (dom/div #js {:className "image-container"}
                       (dom/img #js {:className "preview"
                                     :src (:preview data)}
                                nil))
              (dom/span #js {:className "created"}
                        (. (js/moment (:created data)) format "L LT"))))))

(defn Strokes [data owner]
  (reify
    om/IRender
    (render [this]
      (dom/div #js {:id "strokes-list"}
               (dom/div #js {:className "stroke-menu"}
                        (dom/span nil "Strokes"))
               (apply dom/ul #js {:className "stroke-items"}
                      (om/build-all Stroke (:cats data)))))))
