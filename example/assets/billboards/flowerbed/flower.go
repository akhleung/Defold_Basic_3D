components {
  id: "model"
  component: "/example/assets/billboards/flowerbed/flower.model"
  position {
    y: 0.5
  }
}
components {
  id: "script"
  component: "/example/assets/billboards/flowerbed/flower.script"
}
components {
  id: "billboard"
  component: "/defrend/scripts/controllers/billboard.script"
  properties {
    id: "pitch_factor"
    value: "0.5"
    type: PROPERTY_TYPE_NUMBER
  }
}
