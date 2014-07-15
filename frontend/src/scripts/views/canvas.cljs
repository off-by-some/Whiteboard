(ns whiteboard.canvas
  (:require [cljs.core :as core]
            [om.core :as om :include-macros true]
            [om.dom :as dom :include-macros true]
            [whiteboard.strokes :as strokes]))

(defn random-cats [num]
  (map (fn [n]
         (let [size (+ 140 n)]
           {:preview (str "http://www.placekitten.com/" size "/" size)
            :stroke-number n
            :created (js/moment)}))
       (core/range num)))

(defn update-menu-icon [open]
  (str "menu-icon icon-chevron-" (if open "up" "down")))

(defn update-toggle-switch [active]
  (str "toggle-switch" (if active " active" "")))

(defn update-menu-items [visible]
  (str "menu-items" (if visible " visible" "")))

(defn Canvas [data owner]
  (reify
    om/IInitState
    (init-state [this]
      {:menu false})
    om/IRenderState
    (render-state [this state]
      (dom/div #js {:id "canvas"}
               (dom/div #js {:className "title"}
                        (dom/h1 nil
                                "Start Drawing Here"))
               (dom/div #js {:className "menu-selector"}
                        (dom/div #js {:className (update-toggle-switch
                                                  (:menu state))
                                      :onClick (fn [_]
                                                 (om/update-state! owner
                                                                   :menu
                                                                   not))}
                                 (dom/span nil "Menu")
                                 (dom/i #js {:className (update-menu-icon
                                                         (:menu state))}
                                        nil))
                        (dom/ul #js {:className (update-menu-items
                                                 (:menu state))}
                                (dom/li #js {:className "file"}
                                        (dom/i #js {:className "icon-file"}
                                               nil)
                                        (dom/span nil "File"))
                                (dom/li #js {:className "brushes"}
                                        (dom/i #js {:className "icon-pencil"}
                                               nil)
                                        (dom/span nil "Brushes"))
                                (dom/li #js {:className "tools"}
                                        (dom/i #js {:className "icon-magic"}
                                               nil)
                                        (dom/span nil "Tools"))
                                (dom/li #js {:className "settings"}
                                        (dom/i #js {:className "icon-cogs"}
                                               nil)
                                        (dom/span nil "Settings"))
                                (dom/li #js {:className "share"}
                                        (dom/i #js {:className "icon-ticket"}
                                               nil)
                                        (dom/span nil "Share"))))
               (dom/div #js {:className "canvas-strokes"}
                        (om/build strokes/Strokes {:cats (random-cats 10)}))
               (dom/ul #js {:className "items"} nil)))))

(om/root Canvas {}
         {:target js/document.body})
