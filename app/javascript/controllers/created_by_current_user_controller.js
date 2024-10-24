import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { selector: String }
  static classes = [ "differentiator" ]

  connect() {
    this.#createdElements.forEach(el => el.classList.add(this.differentiatorClass))
  }

  get #createdElements() {
    return this.element.querySelectorAll(this.#selector)
  }

  get #selector() {
    return `${this.selectorValue}[data-creator-id='${Current.user.id}']`
  }
}
