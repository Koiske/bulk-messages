import { ajax } from "discourse/lib/ajax"
import { popupAjaxError } from "discourse/lib/ajax-error"

export default Ember.Controller.extend({
  actions: {
    action() {
      this.set("loading", true)
      this.set("success", false)

      ajax("/admin/plugins/discourse-bulk-messages", {
				data: {
          anonymous: this.get("anonymous"),
          closed: this.get("closed"),
          group: this.get("pm_group"),
          raw: this.get("pm_body"),
          title: this.get("pm_title"),
          usernames: this.get("pm_users").split("\n"),
				},

				method: "POST"
			}).then(() => {
				this.set("success", true)
			}).catch(popupAjaxError).finally(() => {
        this.set("loading", false)
      })
    }
  }
})
