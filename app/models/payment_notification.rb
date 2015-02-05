class PaymentNotification < ActiveRecord::Base
  attr_accessible :params, :reference_code, :invoice_id, :payment_status, :transaction_id, :env_headers
  #one way belongs_to since this is a specific implementation and might change forward.
  #   everything past the invoice in the workflow is on it's own for associations
  belongs_to :invoice
  serialize :params
  after_create :synchronize_with_system

 

  def synchronize_with_system
    #get the invoice lined up.
    link_to_and_marshall_invoice
  end
   private
  # SystemMessage struct
  # t.text :message
  # t.string :reference_class_type
  # t.integer :reference_id
  # t.string :calling_method
  # t.text :exception_audit
  # t.string :priority
  # t.string :status
  
  def link_to_and_marshall_invoice
    #an invoice can only be transacted once
    payments = PaymentNotification.where(:reference_code => self.reference_code)
    
    unless payments.count == 0
    
    matches = Invoice.where(:reference_code => self.reference_code).order('id asc') #oldest first in case there are multi.
    
      if matches.count==0
        SystemMessage.new(:message => "POSSIBLE ATTACK!! : No Invoice with reference_code found : #{self.reference_code}.", 
        :reference_class_type => "PaymentNotification",
        :reference_id => self.id,
        :calling_method => "PaymentNotification.link_to_and_marshall_invoice",
        :priority => "WARN"
        ).save
      else
        #find the referenced invoice and discard if invoice is already handled.
        if matches.count > 1 
          #we will use the first (original?) invoice in case it's by back/refresh issue with browser
          invoice_object = matches.first
          SystemMessage.new(:message => "Duplicate Invoice reference_code found : #{self.reference_code}, using first in resultset Invoice[#{invoice_object.id}] ",
          :reference_class_type => "PaymentNotification", 
          :reference_id => self.id, 
          :calling_method => "PaymentNotification.link_to_and_marshall_invoice", 
          :priority => "WARN").save
        else
          invoice_object= Invoice.find_by_id( matches )
        end
        puts "**** Invoice object : #{invoice_object.inspect} class:#{invoice_object.class}"
        if invoice_object.status == 'paid'
          # we don't want to re-apply this transaction.
          SystemMessage.new(:message => "Duplicate Payment Transaction :(# #{self.transaction_id}/internal_id:#{self.id}) Invoice #{invoice_object.id} is already paid.", 
          :reference_class_type => "PaymentNotification",
          :reference_id => self.id,
          :calling_method => "PaymentNotification.link_to_and_marshall_invoice",
          :priority => "WARN"
          ).save
        else
         
          if self.payment_status=="APPROVED"
            invoice_updated = false 
            self.invoice_id = invoice_object.id
            self.save
            invoice_object.reservation_carts.each do |cart|
              cart.status='paid'
              cart.reservation.locked = true
              if cart.reservation.save
               if cart.save
                 unless invoice_updated
                   # TODO: create a good payment
                   #new_payment = Payment.new(:invoice_id=>invoice_object.id, :payment_method=>"FirstData", :refcode=>self.transaction_id, :status=>self.params[:status], :payment_amount=>self.params.[:chargetotal])
                   #new_payment.save
                   
                   invoice_object.status="paid"
                   invoice_object.payment_type="FirstData"
                   invoice_object.payment_date=self.params[:txndate_processed]
                   invoice_object.save
                 end
               end
             end
            end
          else
            # do nothing more than link it up, we need them to see all transactions attempted
            self.invoice_id = invoice_object.id          
          end
          invoice_object.save
          self.save
        end
      
      end  #end of nilcheck fallthrough
    end #end of making sure we don' already have a linked notification
  end

  def create_invoice_payment
    
  end

  def mark_cart_as_purchased
    #link to the invoice and mark it as paid
    if payment_status == "Completed"
      # cart.update_attribute(:purchased_at, Time.now)
      puts "Yay, we have paid #{params[:invoice_id]}"
    else
      puts "Boo, we failed"
    end
    redirect_to "/reservation_carts/"
  end
end
