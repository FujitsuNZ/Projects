<aura:application >
	<!-- Include the SLDS static resource -->
    <ltng:require styles="{!$Resource.SLDS203 + '/assets/styles/salesforce-lightning-design-system-ltng.css'}"/> 
    <div class="slds">
        <div class="slds-page-header">
            <div class="slds-grid">
                <div class="slds-col slds-has-flexi-truncate">
                    <p class="slds-text-heading--label">Cases</p>
                    <div class="slds-grid">
                        <div class="slds-grid slds-type-focus slds-no-space">
                            <h1 class="slds-text-heading--medium slds-truncate" title="My Case">My Cases</h1>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</aura:application>