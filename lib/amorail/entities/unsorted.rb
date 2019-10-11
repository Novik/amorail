module Amorail
  # AmoCRM lead entity
  class Unsorted < Amorail::Entity

    attr_accessor :contacts, :leads, :pipeline_id, :form_id, :form_page
    validates :form_id, :form_page, presence: true

    def initialize(*args)
      super
      self.contacts ||= []
      self.leads ||= []
    end

    protected

    def create_params(method)
      ret = 
      {
         created_at: Time.now.to_i,
         incoming_entities: 
         {
           leads: [],
           contacts: []
         }, 	
         incoming_lead_info: 
         {
           form_id: self.form_id,
           form_page: self.form_page
         }
      }
      ret[:pipeline_id] = self.pipeline_id if self.pipeline_id.present?
      self.leads.each { |l| ret[:incoming_entities][:leads].push(l.params.except(:last_modified)) }
      self.contacts.each { |c| ret[:incoming_entities][:contacts].push(c.params.except(:last_modified)) }
      { add: [ ret ] }
    end

    def commit_request(attrs)
      client.safe_request(
        :post,
        "/api/v2/incoming_leads/form",
        normalize_params(attrs)
      )
    end

    def handle_response(response, method)
      (response.status == 200) && (response.body['status']=='success')
    end

  end
end
