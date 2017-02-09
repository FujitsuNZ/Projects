<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Active_Recall</fullName>
        <description>Active Recall</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Toyota/Active_Recall</template>
    </alerts>
    <rules>
        <fullName>Active Recall</fullName>
        <actions>
            <name>Active_Recall</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>Active_Recall__c=True</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Follow Up Call</fullName>
        <actions>
            <name>Follow_Up_Call</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Status</field>
            <operation>equals</operation>
            <value>Assigned</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Follow_Up_Call</fullName>
        <assignedTo>vinay.pathak@in.fujitsu.com</assignedTo>
        <assignedToType>user</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Contact.CreatedDate</offsetFromField>
        <priority>High</priority>
        <protected>false</protected>
        <status>In Progress</status>
        <subject>Follow Up Call</subject>
    </tasks>
</Workflow>
