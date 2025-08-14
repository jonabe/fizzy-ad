import { Controller } from "@hotwired/stimulus"

const EDGE_THRESHOLD = 90

export default class extends Controller {
  static targets = [ "dialog" ]
  static values = {
    modal: { type: Boolean, default: false }
  }

  connect() {
    this.dialogTarget.setAttribute('aria-hidden', 'true')
  }

  open() {
    const modal = this.modalValue

    if (modal) {
      this.dialogTarget.showModal()
    } else {
      this.dialogTarget.show()
    }
    this.#orient(this.dialogTarget)
    this.dialogTarget.setAttribute('aria-hidden', 'false')
    this.dispatch("show")
  }

  toggle() {
    if (this.dialogTarget.open) {
      this.close()
    } else {
      this.open()
    }
  }

  close() {
    this.dialogTarget.close()
    this.dialogTarget.setAttribute('aria-hidden', 'true')
    this.dialogTarget.blur()
  }

  closeOnClickOutside({ target }) {
    if (!this.element.contains(target)) this.close()
  }

  #orient(element) {
    element.classList.toggle("orient-left", this.#distanceToRight < EDGE_THRESHOLD)
    element.classList.toggle("orient-right", this.#distanceToLeft < EDGE_THRESHOLD)
    element.classList.toggle("orient-top", this.#distanceToBottom < EDGE_THRESHOLD)
  }

  get #distanceToLeft() {
    return this.#boundingClientRect.left
  }

  get #distanceToRight() {
    return window.innerWidth - this.#boundingClientRect.right
  }

  get #distanceToBottom() {
    return window.innerHeight - this.#boundingClientRect.bottom
  }

  get #boundingClientRect() {
    return this.dialogTarget.getBoundingClientRect()
  }
}
