<!--
 - Created by kwn687 on 2021-10-21.
 -->

<aura:application description="searchApp">
    <aura:attribute name="search" type="String" />
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    Redirecting to search results for {!v.search}
</aura:application>