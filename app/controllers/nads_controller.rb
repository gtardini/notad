class NadsController < ApplicationController
  # GET /nads
  # GET /nads.xml
  
  #baseurl for the creation of the outboundlink in the nad
  #@baseurl = "http://localhost:3000/"
  
  def index
    @nads = Nad.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @nads }
    end
  end

  # GET /nads/1
  # GET /nads/1.xml
  def show
    @nad = Nad.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @nad }
    end
  end

  # GET /nads/new
  # GET /nads/new.xml
  def new
    @nad = Nad.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @nad }
    end
  end

  # GET /nads/1/edit
  def edit
    @nad = Nad.find(params[:id])
  end










  # POST /nads
  # POST /nads.xml
  def create
    @nad = Nad.new(params[:nad])
    #automatically infer domain from outboundlink
    dname = URI.parse( "http://" + @nad.outboundlink).host
    
    #if the domain doesn't exists
    @domain = Domain.find_by_name(dname)
    if @domain
      @nad.domain_id = @domain.id
    else
      @domain = Domain.new(:name => dname)
      @domain.save!
      #build automatically assigns domain_id to the nad
      @nad = @domain.nads.build(:outboundlink => @nad.outboundlink, :imgurl => @nad.outboundlink, :head => @nad.head, :caption => @nad.caption, :approved => 0)
    end
    
    respond_to do |format|
      if @nad.save
        format.html { redirect_to(@nad, :notice => 'Nad was successfully created.') }
        format.xml  { render :xml => @nad, :status => :created, :location => @nad }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @nad.errors, :status => :unprocessable_entity }
      end
    end
  end












  # PUT /nads/1
  # PUT /nads/1.xml
  def update
    @nad = Nad.find(params[:id])

    respond_to do |format|
      if @nad.update_attributes(params[:nad])
        format.html { redirect_to(@nad, :notice => 'Nad was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @nad.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /nads/1
  # DELETE /nads/1.xml
  def destroy
    @nad = Nad.find(params[:id])
    @nad.destroy

    respond_to do |format|
      format.html { redirect_to(nads_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def serve
    #TODO: AGGIUNGERE UN PO' DI ROTAZIONE, IN MODO CHE NON SIANO VISUALIZZATI SEMPRE E SOLO GLI AD CON PIUì CREDITI
    
    #QUESTO SISTEMA NON E' MOLTO EFFICIENTE ED E' PIUTTOSTO COMPUTATIONALLY INTENSIVE... TROVA QUALCOSA DI MEGLIO
    @fromdomain = Domain.find_by_name(params[:fromdomain])

    #DEPRECATED COMMENT, BUT I KEEP IT AS A SOUVENIR------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #COMMENT OUT LINES 129, 132, 134, 162 PER AVERE LA VERSIONE FUNZIONANTE DI PRIMA DEL VIAGGIO SAN FRANCISCO - PHILADELPHIA, SENZA L' ABBOZZO DEL CALCOLO DEI CREDITI
    #------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    #trova il nad migliore fra quelli dei domini creditori di fromdomain
    @nad = choose_best_from_creditors(@fromdomain)
    
    #se il nad è stato trovato tra quelli creditori visualizza quello, altrimenti...
    if @nad
      #@nad = @nad
    else
      #...sceglie un nad a caso
      @nad = Nad.all
      length = @nad.length - 1
      nad_iterator = (0..length).to_a
      current_nad = nad_iterator.choice
    
      #loop infinito finchè non viene trovato un nad che non sia mai stato visualizzato sul dominio corrente
      while true do
        #se il nad corrente non è stato ancora visualizzato sul dominio attuale..
        if @nad[current_nad].views.find_all_by_viewedon(@fromdomain.id).length == 0
          # ...crea una visualizzazione per il nad corrente al dominio su cui è stato visualizzato...
          @nad = @nad[current_nad]
          @nad.views.create!(:viewedon => @fromdomain.id)
          break
        else
          # ...altrimenti sceglie a caso un altro nad, e così via.
          #siccome quel nad era già stato visualizzato nel dominio corrente, viene rimosso dai valori tra cui scegliere
          if (nad_iterator -= current_nad.to_a) == []
            #se tutti i nads sono stati visualizzati su questo dominio sceglie quello che ha meno visualizzazioni
            @nad = choose_less_viewed(@fromdomain)
            @nad.views.create!(:viewedon => @fromdomain.id)
            break
          else
            #imposta casualmente il prossimo valore dell' iteratore
            current_nad = nad_iterator.to_a.choice
          end
        end
      end
    end

    #fromdomain e outboundlink vengono inclusi nell' src dello script javascript distribuito
    render :text => javascript(params[:fromdomain], @nad.id, @nad.outboundlink)
  end
  
  def click
    @nad = Nad.find(params[:nad_id])
    @tourl = @nad.outboundlink
    #posso scrivere @nad.domain perchè in Nad c' è la foreign key domain_id
    @todomain = @nad.domain
    
    #find the domain from which the request came from
    @fromdomain = Domain.find_by_name(params[:fromdomain])
    #creates a new relationship where the debtor_id is the id of the domain to which the outboundlink points
    @relationship = Relationship.create!(:debtor_id => @todomain.id, :creditor_id => @fromdomain.id)
    
    #sistemare il collegamento
    #@nad = @fromdomain.nads.find_by_outboundlink(@tourl)
    
    #redirect finale alla landing page
    #redirect_to "http://" + @tourl
  end
  
  
  private
  
  
    #QUESTO E' VERAMENTE ORRIBILE, RISCRIVI QUESTA FUNZIONE CON IL PARADIGMA JSONP http://www.onlinesolutionsdevelopment.com/blog/web-development/javascript/jsonp-example/
    def javascript(fromdomain, nad_id, linkname)
      #builds the outboundlink with the following rule match "/click/:nad_id/:fromdomain", :constraints => {:fromdomain => /.*/ }, :to => "nads#click"
      @outboundlink = "http://localhost:3000/" + "click/" + nad_id.to_s + "/" + fromdomain
      
      return "(function(j, l, v) {

      	config = {};
          try {
              config = __spr_config
          } catch(U) {}

      	//appends CSS
      	var css = document.createElement('link');
      	css.setAttribute(\"rel\", \"stylesheet\");
      	css.setAttribute(\"type\", \"text/css\");
      	css.setAttribute(\"href\", config.css);
      	(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(css);

      	//appends NAD canvas
      	var nad = document.createElement('div');
      	nad.setAttribute(\"id\", \"nad\");
      	nad.setAttribute(\"class\", \"boxgrid caption\")
      	document.getElementsByTagName('body')[0].appendChild(nad);

      	//fills NAD canvas with actual elements
      	//TODO don't make them appear as long as they aren't styled
      	j.onload = function(){
      		document.getElementById(\"nad\").innerHTML = \"<img src='http://gtardini.com/crossnet/jsembed/nonsense.jpg'></img><div class='cover boxcaption'><h3>HEAD</h3><p>CAPTION<br/><a href='#{@outboundlink}'>http://#{linkname}</a></p></div>\";
      		//adds	js controllers and effects, needs jQuery
        	$('.boxgrid.slidedown').hover(function(){
        		$(\".cover\", this).stop().animate({top:'-260px'},{queue:false,duration:300});
        	}, function() {
        		$(\".cover\", this).stop().animate({top:'0px'},{queue:false,duration:300});
        	});

        	$('.boxgrid.slideright').hover(function(){
        		$(\".cover\", this).stop().animate({left:'325px'},{queue:false,duration:300});
        	}, function() {
        		$(\".cover\", this).stop().animate({left:'0px'},{queue:false,duration:300});
        	});

        	$('.boxgrid.thecombo').hover(function(){
        		$(\".cover\", this).stop().animate({top:'260px', left:'325px'},{queue:false,duration:300});
        	}, function() {
        		$(\".cover\", this).stop().animate({top:'0px', left:'0px'},{queue:false,duration:300});
        	});

        	$('.boxgrid.peek').hover(function(){
        		$(\".cover\", this).stop().animate({top:'90px'},{queue:false,duration:160});
        	}, function() {
        		$(\".cover\", this).stop().animate({top:'0px'},{queue:false,duration:160});
        	});

        	$('.boxgrid.captionfull').hover(function(){
        		$(\".cover\", this).stop().animate({top:'160px'},{queue:false,duration:160});
        	}, function() {
        		$(\".cover\", this).stop().animate({top:'260px'},{queue:false,duration:160});
        	});

        	$('.boxgrid.caption').hover(function(){
        		$(\".cover\", this).stop().animate({top:'160px'},{queue:false,duration:160});
        	}, 
        	function() {
        		$(\".cover\", this).stop().animate({top:'220px'},{queue:false,duration:160});
        	});
      	}


      })(window, document, document.location.protocol);"
    end
    
    def choose_best_from_creditors(fromdomain)
      #TODO : TEST CON UN DOMINIO SENZA CREDITORS
      number_of_creditors = []
      for creditor in fromdomain.creditors
        number_of_creditors << creditor.id
      end
      if number_of_creditors != []
        # make the hash default to 0 so that += will work correctly
        b = Hash.new(0)
        # iterate over the array, counting duplicate entries
        number_of_creditors.each do |v|
          b[v] += 1
        end
        #controlla tutti i creditori del fromdomain, e sceglie quello con il rapporto crediti-debiti maggiore
        for value in b.values.sort.reverse
          chosen_id = b.select {|creditor_id, n| n == value}[0][0]
          chosen = Nad.find_by_domain_id(chosen_id)

          #trova i crediti e i debiti del fromdomain nei confronti del todomain
          todomain = chosen.domain
          fromdomain_credits = todomain.creditors.find_all_by_id(fromdomain.id).length
          fromdomain_debts = todomain.debtors.find_all_by_id(fromdomain.id).length
          #visualizza il nad solo se il fromdomain è in debito col todomain
          if chosen && (fromdomain_debts > fromdomain_credits)
            return chosen
          end
        end
        return nil
      else
        return nil
      end
    end
    
    def choose_less_viewed(fromdomain)
      #inizializza un hash vuoto in cui verranno inserite le coppie id_del_nad e numero_di_views_sul_fromdomain
      number_of_views = {}
    	
    	#per ogni nad
      for nad in @nad do
        #controlla quante visualizzazioni ha sul fromdomain
        n = nad.views.find_all_by_viewedon(fromdomain.id).length
        nadid = nad.id
        #salva nell' hash la coppia id_del_nad e numero_di_views_sul_fromdomain
        number_of_views.store(nadid, n)
      end
      #trova il valore minimo di visualizzazioni
      min = number_of_views.values.min
      #returns un hash popolato dalle coppie in cui il numero di visualizzazioni è pari al valore minimo
      lessviewed = number_of_views.select {|nadid, n| n == min}
      
      #se nell' hash ci sono più di una coppia...
      if lessviewed.length != 1
        #...sceglie a caso un numero nel range di grandezza dell' array
        i = (0..(lessviewed.length - 1)).to_a
        n = i.choice
        #ritorna un array non associativo scegliendo dall' hash la coppia casuale
        lessviewed = lessviewed[n]
      else
        #sceglie l' unica coppia dell' hash
        lessviewed = lessviewed[0]
      end
      
      #devo mettere 0 perchè lessviewed[n] nell' if o lessviewed[0] nell' else hanno dato come risultato non un valore unico ma un array (non un hash) nel formato [nadid, n]
      return Nad.find(lessviewed[0])
    end
end
