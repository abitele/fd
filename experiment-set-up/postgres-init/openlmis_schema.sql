--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO postgres;

--
-- Name: cce; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA cce;


ALTER SCHEMA cce OWNER TO postgres;

--
-- Name: fulfillment; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA fulfillment;


ALTER SCHEMA fulfillment OWNER TO postgres;

--
-- Name: notification; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA notification;


ALTER SCHEMA notification OWNER TO postgres;

--
-- Name: referencedata; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA referencedata;


ALTER SCHEMA referencedata OWNER TO postgres;

--
-- Name: report; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA report;


ALTER SCHEMA report OWNER TO postgres;

--
-- Name: requisition; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA requisition;


ALTER SCHEMA requisition OWNER TO postgres;

--
-- Name: stockmanagement; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA stockmanagement;


ALTER SCHEMA stockmanagement OWNER TO postgres;

--
-- Name: template; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA template;


ALTER SCHEMA template OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = requisition, pg_catalog;

--
-- Name: unique_status_changes(); Type: FUNCTION; Schema: requisition; Owner: postgres
--

CREATE FUNCTION unique_status_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
supervisoryNode uuid;
previousSupervisoryNode uuid;
requisitionStatus character varying(255);
previousStatus character varying(255);
BEGIN

  SELECT status, supervisorynodeid
  INTO requisitionstatus, supervisoryNode
  FROM requisition.status_changes
  WHERE requisitionid = NEW.requisitionid
  ORDER BY createddate DESC
  LIMIT 1;

  SELECT status, supervisorynodeid
  INTO previousStatus, previousSupervisoryNode
  FROM requisition.status_changes
  WHERE requisitionid = NEW.requisitionid
  ORDER BY createddate DESC
  LIMIT 1 OFFSET 1;

  IF (previousSupervisoryNode IS NULL OR previousSupervisoryNode = supervisoryNode) AND previousStatus = requisitionStatus
  THEN
    RAISE 'Duplicate status change: % at supervisory node: % ', NEW.status, NEW.supervisoryNodeId USING ERRCODE = 'unique_violation';
  ELSE
    RETURN NEW;
  END IF;

END $$;


ALTER FUNCTION requisition.unique_status_changes() OWNER TO postgres;

SET search_path = auth, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: api_keys; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE api_keys (
    token uuid NOT NULL,
    createdby uuid NOT NULL,
    createddate timestamp with time zone NOT NULL,
    clientid character varying(255) NOT NULL
);


ALTER TABLE api_keys OWNER TO postgres;

--
-- Name: auth_users; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE auth_users (
    id uuid NOT NULL,
    enabled boolean,
    password character varying(255),
    username character varying(255) NOT NULL
);


ALTER TABLE auth_users OWNER TO postgres;

--
-- Name: data_loaded; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE data_loaded (
);


ALTER TABLE data_loaded OWNER TO postgres;

--
-- Name: oauth_access_token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE oauth_access_token (
    tokenid character varying(256),
    token bytea,
    authenticationid character varying(256),
    username character varying(256),
    clientid character varying(256),
    authentication bytea,
    refreshtoken character varying(256)
);


ALTER TABLE oauth_access_token OWNER TO postgres;

--
-- Name: oauth_approvals; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE oauth_approvals (
    userid character varying(256),
    clientid character varying(256),
    scope character varying(256),
    status character varying(10),
    expiresat timestamp without time zone,
    lastmodifiedat timestamp without time zone
);


ALTER TABLE oauth_approvals OWNER TO postgres;

--
-- Name: oauth_client_details; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE oauth_client_details (
    clientid character varying(255) NOT NULL,
    accesstokenvalidity integer,
    additionalinformation character varying(255),
    authorities character varying(255),
    authorizedgranttypes character varying(255),
    autoapprove character varying(255),
    clientsecret character varying(255),
    refreshtokenvalidity integer,
    redirecturi character varying(255),
    resourceids character varying(255),
    scope character varying(255),
    webserverredirecturi character varying(255)
);


ALTER TABLE oauth_client_details OWNER TO postgres;

--
-- Name: oauth_client_token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE oauth_client_token (
    tokenid character varying(256),
    token bytea,
    authenticationid character varying(256),
    username character varying(256),
    clientid character varying(256)
);


ALTER TABLE oauth_client_token OWNER TO postgres;

--
-- Name: oauth_code; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE oauth_code (
    code character varying(256),
    authentication bytea
);


ALTER TABLE oauth_code OWNER TO postgres;

--
-- Name: oauth_refresh_token; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE oauth_refresh_token (
    tokenid character varying(256),
    token bytea,
    authentication bytea
);


ALTER TABLE oauth_refresh_token OWNER TO postgres;

--
-- Name: password_reset_tokens; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE password_reset_tokens (
    id uuid NOT NULL,
    expirydate timestamp with time zone NOT NULL,
    userid uuid NOT NULL
);


ALTER TABLE password_reset_tokens OWNER TO postgres;

--
-- Name: schema_version; Type: TABLE; Schema: auth; Owner: postgres
--

CREATE TABLE schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE schema_version OWNER TO postgres;

SET search_path = cce, pg_catalog;

--
-- Name: cce_alert_status_messages; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE cce_alert_status_messages (
    alertid uuid NOT NULL,
    locale text NOT NULL,
    message text
);


ALTER TABLE cce_alert_status_messages OWNER TO postgres;

--
-- Name: cce_alerts; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE cce_alerts (
    id uuid NOT NULL,
    externalid character varying(64) NOT NULL,
    type text NOT NULL,
    inventoryitemid uuid NOT NULL,
    starttimestamp timestamp with time zone NOT NULL,
    endtimestamp timestamp with time zone,
    dismisstimestamp timestamp with time zone,
    active boolean
);


ALTER TABLE cce_alerts OWNER TO postgres;

--
-- Name: cce_catalog_items; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE cce_catalog_items (
    id uuid NOT NULL,
    frompqscatalog boolean NOT NULL,
    equipmentcode text,
    type text NOT NULL,
    model text NOT NULL,
    manufacturer text NOT NULL,
    energysource text NOT NULL,
    dateofprequal integer,
    storagetemperature text NOT NULL,
    maxoperatingtemp integer,
    minoperatingtemp integer,
    energyconsumption text,
    holdovertime integer,
    grossvolume integer,
    netvolume integer,
    width integer,
    depth integer,
    height integer,
    visibleincatalog boolean,
    archived boolean NOT NULL
);


ALTER TABLE cce_catalog_items OWNER TO postgres;

--
-- Name: cce_inventory_items; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE cce_inventory_items (
    id uuid NOT NULL,
    facilityid uuid NOT NULL,
    catalogitemid uuid NOT NULL,
    programid uuid NOT NULL,
    equipmenttrackingid text,
    yearofinstallation integer NOT NULL,
    yearofwarrantyexpiry integer,
    source text,
    functionalstatus text NOT NULL,
    reasonnotworkingornotinuse text,
    utilization text NOT NULL,
    voltagestabilizer text NOT NULL,
    backupgenerator text NOT NULL,
    voltageregulator text NOT NULL,
    manualtemperaturegauge text NOT NULL,
    remotetemperaturemonitorid text,
    additionalnotes text,
    modifieddate timestamp with time zone,
    lastmodifierid uuid,
    referencename text NOT NULL,
    decommissiondate date,
    remotetemperaturemonitor text NOT NULL
);


ALTER TABLE cce_inventory_items OWNER TO postgres;

--
-- Name: data_loaded; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE data_loaded (
);


ALTER TABLE data_loaded OWNER TO postgres;

--
-- Name: jv_commit; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE jv_commit (
    commit_pk bigint NOT NULL,
    author character varying(200),
    commit_date timestamp without time zone,
    commit_id numeric(22,2)
);


ALTER TABLE jv_commit OWNER TO postgres;

--
-- Name: jv_commit_pk_seq; Type: SEQUENCE; Schema: cce; Owner: postgres
--

CREATE SEQUENCE jv_commit_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_commit_pk_seq OWNER TO postgres;

--
-- Name: jv_commit_property; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE jv_commit_property (
    property_name character varying(200) NOT NULL,
    property_value character varying(600),
    commit_fk bigint NOT NULL
);


ALTER TABLE jv_commit_property OWNER TO postgres;

--
-- Name: jv_global_id; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE jv_global_id (
    global_id_pk bigint NOT NULL,
    local_id character varying(200),
    fragment character varying(200),
    type_name character varying(200),
    owner_id_fk bigint
);


ALTER TABLE jv_global_id OWNER TO postgres;

--
-- Name: jv_global_id_pk_seq; Type: SEQUENCE; Schema: cce; Owner: postgres
--

CREATE SEQUENCE jv_global_id_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_global_id_pk_seq OWNER TO postgres;

--
-- Name: jv_snapshot; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE jv_snapshot (
    snapshot_pk bigint NOT NULL,
    type character varying(200),
    version bigint,
    state text,
    changed_properties text,
    managed_type character varying(200),
    global_id_fk bigint,
    commit_fk bigint
);


ALTER TABLE jv_snapshot OWNER TO postgres;

--
-- Name: jv_snapshot_pk_seq; Type: SEQUENCE; Schema: cce; Owner: postgres
--

CREATE SEQUENCE jv_snapshot_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_snapshot_pk_seq OWNER TO postgres;

--
-- Name: schema_version; Type: TABLE; Schema: cce; Owner: postgres
--

CREATE TABLE schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE schema_version OWNER TO postgres;

SET search_path = fulfillment, pg_catalog;

--
-- Name: configuration_settings; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE configuration_settings (
    key character varying(255) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE configuration_settings OWNER TO postgres;

--
-- Name: data_loaded; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE data_loaded (
);


ALTER TABLE data_loaded OWNER TO postgres;

--
-- Name: jv_commit; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE jv_commit (
    commit_pk bigint NOT NULL,
    author character varying(200),
    commit_date timestamp without time zone,
    commit_id numeric(22,2)
);


ALTER TABLE jv_commit OWNER TO postgres;

--
-- Name: jv_commit_pk_seq; Type: SEQUENCE; Schema: fulfillment; Owner: postgres
--

CREATE SEQUENCE jv_commit_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_commit_pk_seq OWNER TO postgres;

--
-- Name: jv_commit_property; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE jv_commit_property (
    property_name character varying(200) NOT NULL,
    property_value character varying(600),
    commit_fk bigint NOT NULL
);


ALTER TABLE jv_commit_property OWNER TO postgres;

--
-- Name: jv_global_id; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE jv_global_id (
    global_id_pk bigint NOT NULL,
    local_id character varying(200),
    fragment character varying(200),
    type_name character varying(200),
    owner_id_fk bigint
);


ALTER TABLE jv_global_id OWNER TO postgres;

--
-- Name: jv_global_id_pk_seq; Type: SEQUENCE; Schema: fulfillment; Owner: postgres
--

CREATE SEQUENCE jv_global_id_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_global_id_pk_seq OWNER TO postgres;

--
-- Name: jv_snapshot; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE jv_snapshot (
    snapshot_pk bigint NOT NULL,
    type character varying(200),
    version bigint,
    state text,
    changed_properties text,
    managed_type character varying(200),
    global_id_fk bigint,
    commit_fk bigint
);


ALTER TABLE jv_snapshot OWNER TO postgres;

--
-- Name: jv_snapshot_pk_seq; Type: SEQUENCE; Schema: fulfillment; Owner: postgres
--

CREATE SEQUENCE jv_snapshot_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_snapshot_pk_seq OWNER TO postgres;

--
-- Name: order_file_columns; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE order_file_columns (
    id uuid NOT NULL,
    columnlabel character varying(255),
    datafieldlabel character varying(255),
    format character varying(255),
    include boolean NOT NULL,
    keypath character varying(255),
    nested character varying(255),
    openlmisfield boolean NOT NULL,
    "position" integer NOT NULL,
    related character varying(255),
    relatedkeypath character varying(255),
    orderfiletemplateid uuid NOT NULL
);


ALTER TABLE order_file_columns OWNER TO postgres;

--
-- Name: order_file_templates; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE order_file_templates (
    id uuid NOT NULL,
    fileprefix character varying(255) NOT NULL,
    headerinfile boolean NOT NULL
);


ALTER TABLE order_file_templates OWNER TO postgres;

--
-- Name: order_line_items; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE order_line_items (
    id uuid NOT NULL,
    orderid uuid NOT NULL,
    orderableid uuid NOT NULL,
    orderedquantity bigint NOT NULL
);


ALTER TABLE order_line_items OWNER TO postgres;

--
-- Name: order_number_configurations; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE order_number_configurations (
    id uuid NOT NULL,
    includeordernumberprefix boolean NOT NULL,
    includeprogramcode boolean NOT NULL,
    includetypesuffix boolean NOT NULL,
    ordernumberprefix character varying(255)
);


ALTER TABLE order_number_configurations OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE orders (
    id uuid NOT NULL,
    createdbyid uuid NOT NULL,
    createddate timestamp with time zone,
    emergency boolean NOT NULL,
    externalid uuid NOT NULL,
    facilityid uuid,
    ordercode text NOT NULL,
    processingperiodid uuid,
    programid uuid NOT NULL,
    quotedcost numeric(19,2) NOT NULL,
    receivingfacilityid uuid NOT NULL,
    requestingfacilityid uuid NOT NULL,
    status character varying(255) NOT NULL,
    supplyingfacilityid uuid NOT NULL,
    lastupdateddate timestamp with time zone NOT NULL,
    lastupdaterid uuid NOT NULL
);


ALTER TABLE orders OWNER TO postgres;

--
-- Name: proof_of_delivery_line_items; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE proof_of_delivery_line_items (
    id uuid NOT NULL,
    proofofdeliveryid uuid NOT NULL,
    notes text,
    quantityaccepted integer,
    quantityrejected integer,
    orderableid uuid NOT NULL,
    lotid uuid,
    vvmstatus character varying(255),
    usevvm boolean DEFAULT false NOT NULL,
    rejectionreasonid uuid
);


ALTER TABLE proof_of_delivery_line_items OWNER TO postgres;

--
-- Name: proofs_of_delivery; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE proofs_of_delivery (
    id uuid NOT NULL,
    shipmentid uuid NOT NULL,
    status text DEFAULT 'INITIATED'::text,
    deliveredby text,
    receivedby text,
    receiveddate date
);


ALTER TABLE proofs_of_delivery OWNER TO postgres;

--
-- Name: schema_version; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE schema_version OWNER TO postgres;

--
-- Name: shipment_draft_line_items; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE shipment_draft_line_items (
    id uuid NOT NULL,
    orderableid uuid NOT NULL,
    lotid uuid,
    quantityshipped bigint,
    shipmentdraftid uuid NOT NULL
);


ALTER TABLE shipment_draft_line_items OWNER TO postgres;

--
-- Name: shipment_drafts; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE shipment_drafts (
    id uuid NOT NULL,
    orderid uuid,
    notes text
);


ALTER TABLE shipment_drafts OWNER TO postgres;

--
-- Name: shipment_line_items; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE shipment_line_items (
    id uuid NOT NULL,
    orderableid uuid NOT NULL,
    lotid uuid,
    quantityshipped bigint NOT NULL,
    shipmentid uuid NOT NULL
);


ALTER TABLE shipment_line_items OWNER TO postgres;

--
-- Name: shipments; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE shipments (
    id uuid NOT NULL,
    orderid uuid,
    shippedbyid uuid NOT NULL,
    shippeddate timestamp with time zone NOT NULL,
    notes text,
    extradata jsonb
);


ALTER TABLE shipments OWNER TO postgres;

--
-- Name: status_changes; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE status_changes (
    id uuid NOT NULL,
    authorid uuid,
    createddate timestamp with time zone,
    status character varying(255) NOT NULL,
    orderid uuid NOT NULL
);


ALTER TABLE status_changes OWNER TO postgres;

--
-- Name: status_messages; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE status_messages (
    id uuid NOT NULL,
    authorid uuid,
    body character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    orderid uuid NOT NULL
);


ALTER TABLE status_messages OWNER TO postgres;

--
-- Name: template_parameters; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE template_parameters (
    id uuid NOT NULL,
    datatype text,
    defaultvalue text,
    description text,
    displayname text,
    name text,
    selectsql text,
    templateid uuid NOT NULL
);


ALTER TABLE template_parameters OWNER TO postgres;

--
-- Name: templates; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE templates (
    id uuid NOT NULL,
    data bytea,
    description text,
    name text NOT NULL,
    type text
);


ALTER TABLE templates OWNER TO postgres;

--
-- Name: transfer_properties; Type: TABLE; Schema: fulfillment; Owner: postgres
--

CREATE TABLE transfer_properties (
    type character varying(31) NOT NULL,
    id uuid NOT NULL,
    facilityid uuid NOT NULL,
    localdirectory text,
    passivemode boolean,
    password text,
    protocol text,
    remotedirectory text,
    serverhost text,
    serverport integer,
    username text,
    path text
);


ALTER TABLE transfer_properties OWNER TO postgres;

SET search_path = notification, pg_catalog;

--
-- Name: email_verification_tokens; Type: TABLE; Schema: notification; Owner: postgres
--

CREATE TABLE email_verification_tokens (
    id uuid NOT NULL,
    expirydate timestamp with time zone NOT NULL,
    emailaddress character varying NOT NULL,
    usercontactdetailsid uuid NOT NULL
);


ALTER TABLE email_verification_tokens OWNER TO postgres;

--
-- Name: notification_messages; Type: TABLE; Schema: notification; Owner: postgres
--

CREATE TABLE notification_messages (
    id uuid NOT NULL,
    notificationid uuid NOT NULL,
    channel text NOT NULL,
    body text NOT NULL,
    subject text
);


ALTER TABLE notification_messages OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: notification; Owner: postgres
--

CREATE TABLE notifications (
    id uuid NOT NULL,
    userid uuid NOT NULL,
    important boolean DEFAULT false,
    createddate timestamp with time zone DEFAULT now()
);


ALTER TABLE notifications OWNER TO postgres;

--
-- Name: schema_version; Type: TABLE; Schema: notification; Owner: postgres
--

CREATE TABLE schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE schema_version OWNER TO postgres;

--
-- Name: user_contact_details; Type: TABLE; Schema: notification; Owner: postgres
--

CREATE TABLE user_contact_details (
    allownotify boolean DEFAULT true,
    email character varying(255) NOT NULL,
    emailverified boolean DEFAULT false NOT NULL,
    phonenumber character varying(255),
    referencedatauserid uuid NOT NULL
);


ALTER TABLE user_contact_details OWNER TO postgres;

SET search_path = referencedata, pg_catalog;

--
-- Name: commodity_types; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE commodity_types (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    classificationsystem character varying(255) NOT NULL,
    classificationid character varying(255) NOT NULL,
    parentid uuid
);


ALTER TABLE commodity_types OWNER TO postgres;

--
-- Name: data_loaded; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE data_loaded (
);


ALTER TABLE data_loaded OWNER TO postgres;

--
-- Name: dispensable_attributes; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE dispensable_attributes (
    dispensableid uuid NOT NULL,
    key text NOT NULL,
    value text NOT NULL
);


ALTER TABLE dispensable_attributes OWNER TO postgres;

--
-- Name: dispensables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE dispensables (
    id uuid NOT NULL,
    type text DEFAULT 'default'::text NOT NULL
);


ALTER TABLE dispensables OWNER TO postgres;

--
-- Name: facilities; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facilities (
    id uuid NOT NULL,
    active boolean NOT NULL,
    code text NOT NULL,
    comment text,
    description text,
    enabled boolean NOT NULL,
    godowndate date,
    golivedate date,
    name text,
    openlmisaccessible boolean,
    geographiczoneid uuid NOT NULL,
    operatedbyid uuid,
    typeid uuid NOT NULL,
    extradata jsonb,
    location public.geometry
);


ALTER TABLE facilities OWNER TO postgres;

--
-- Name: facility_operators; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facility_operators (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    displayorder integer,
    name text
);


ALTER TABLE facility_operators OWNER TO postgres;

--
-- Name: facility_type_approved_products; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facility_type_approved_products (
    id uuid NOT NULL,
    emergencyorderpoint double precision,
    maxperiodsofstock double precision NOT NULL,
    minperiodsofstock double precision,
    facilitytypeid uuid NOT NULL,
    orderableid uuid NOT NULL,
    programid uuid NOT NULL
);


ALTER TABLE facility_type_approved_products OWNER TO postgres;

--
-- Name: facility_types; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE facility_types (
    id uuid NOT NULL,
    active boolean,
    code text NOT NULL,
    description text,
    displayorder integer,
    name text
);


ALTER TABLE facility_types OWNER TO postgres;

--
-- Name: geographic_levels; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE geographic_levels (
    id uuid NOT NULL,
    code text NOT NULL,
    levelnumber integer NOT NULL,
    name text
);


ALTER TABLE geographic_levels OWNER TO postgres;

--
-- Name: geographic_zones; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE geographic_zones (
    id uuid NOT NULL,
    catchmentpopulation integer,
    code text NOT NULL,
    latitude numeric(8,5),
    longitude numeric(8,5),
    name text,
    levelid uuid NOT NULL,
    parentid uuid,
    boundary public.geometry
);


ALTER TABLE geographic_zones OWNER TO postgres;

--
-- Name: ideal_stock_amounts; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE ideal_stock_amounts (
    id uuid NOT NULL,
    facilityid uuid NOT NULL,
    processingperiodid uuid NOT NULL,
    amount integer,
    commoditytypeid uuid NOT NULL
);


ALTER TABLE ideal_stock_amounts OWNER TO postgres;

--
-- Name: jv_commit; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE jv_commit (
    commit_pk bigint NOT NULL,
    author character varying(200),
    commit_date timestamp without time zone,
    commit_id numeric(22,2)
);


ALTER TABLE jv_commit OWNER TO postgres;

--
-- Name: jv_commit_pk_seq; Type: SEQUENCE; Schema: referencedata; Owner: postgres
--

CREATE SEQUENCE jv_commit_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_commit_pk_seq OWNER TO postgres;

--
-- Name: jv_commit_property; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE jv_commit_property (
    property_name character varying(200) NOT NULL,
    property_value character varying(600),
    commit_fk bigint NOT NULL
);


ALTER TABLE jv_commit_property OWNER TO postgres;

--
-- Name: jv_global_id; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE jv_global_id (
    global_id_pk bigint NOT NULL,
    local_id character varying(200),
    fragment character varying(200),
    type_name character varying(200),
    owner_id_fk bigint
);


ALTER TABLE jv_global_id OWNER TO postgres;

--
-- Name: jv_global_id_pk_seq; Type: SEQUENCE; Schema: referencedata; Owner: postgres
--

CREATE SEQUENCE jv_global_id_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_global_id_pk_seq OWNER TO postgres;

--
-- Name: jv_snapshot; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE jv_snapshot (
    snapshot_pk bigint NOT NULL,
    type character varying(200),
    version bigint,
    state text,
    changed_properties text,
    managed_type character varying(200),
    global_id_fk bigint,
    commit_fk bigint
);


ALTER TABLE jv_snapshot OWNER TO postgres;

--
-- Name: jv_snapshot_pk_seq; Type: SEQUENCE; Schema: referencedata; Owner: postgres
--

CREATE SEQUENCE jv_snapshot_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_snapshot_pk_seq OWNER TO postgres;

--
-- Name: lots; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE lots (
    id uuid NOT NULL,
    lotcode text NOT NULL,
    expirationdate date,
    manufacturedate date,
    tradeitemid uuid NOT NULL,
    active boolean NOT NULL
);


ALTER TABLE lots OWNER TO postgres;

--
-- Name: orderable_display_categories; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE orderable_display_categories (
    id uuid NOT NULL,
    code character varying(255),
    displayname character varying(255),
    displayorder integer NOT NULL
);


ALTER TABLE orderable_display_categories OWNER TO postgres;

--
-- Name: orderable_identifiers; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE orderable_identifiers (
    key character varying(255) NOT NULL,
    value character varying(255) NOT NULL,
    orderableid uuid NOT NULL
);


ALTER TABLE orderable_identifiers OWNER TO postgres;

--
-- Name: orderables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE orderables (
    id uuid NOT NULL,
    fullproductname character varying(255),
    packroundingthreshold bigint NOT NULL,
    netcontent bigint NOT NULL,
    code character varying(255),
    roundtozero boolean NOT NULL,
    description character varying(255),
    extradata jsonb,
    dispensableid uuid NOT NULL
);


ALTER TABLE orderables OWNER TO postgres;

--
-- Name: processing_periods; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE processing_periods (
    id uuid NOT NULL,
    description text,
    enddate date NOT NULL,
    name text NOT NULL,
    startdate date NOT NULL,
    processingscheduleid uuid NOT NULL
);


ALTER TABLE processing_periods OWNER TO postgres;

--
-- Name: processing_schedules; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE processing_schedules (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    modifieddate timestamp with time zone,
    name text NOT NULL
);


ALTER TABLE processing_schedules OWNER TO postgres;

--
-- Name: program_orderables; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE program_orderables (
    id uuid NOT NULL,
    active boolean NOT NULL,
    displayorder integer NOT NULL,
    dosesperpatient integer,
    fullsupply boolean NOT NULL,
    priceperpack numeric(19,2),
    orderabledisplaycategoryid uuid NOT NULL,
    orderableid uuid NOT NULL,
    programid uuid NOT NULL
);


ALTER TABLE program_orderables OWNER TO postgres;

--
-- Name: programs; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE programs (
    id uuid NOT NULL,
    active boolean,
    code character varying(255),
    description text,
    name text,
    periodsskippable boolean NOT NULL,
    shownonfullsupplytab boolean,
    enabledatephysicalstockcountcompleted boolean NOT NULL,
    skipauthorization boolean DEFAULT false
);


ALTER TABLE programs OWNER TO postgres;

--
-- Name: requisition_group_members; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisition_group_members (
    requisitiongroupid uuid NOT NULL,
    facilityid uuid NOT NULL
);


ALTER TABLE requisition_group_members OWNER TO postgres;

--
-- Name: requisition_group_program_schedules; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisition_group_program_schedules (
    id uuid NOT NULL,
    directdelivery boolean NOT NULL,
    dropofffacilityid uuid,
    processingscheduleid uuid NOT NULL,
    programid uuid NOT NULL,
    requisitiongroupid uuid NOT NULL
);


ALTER TABLE requisition_group_program_schedules OWNER TO postgres;

--
-- Name: requisition_groups; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE requisition_groups (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    name text NOT NULL,
    supervisorynodeid uuid NOT NULL
);


ALTER TABLE requisition_groups OWNER TO postgres;

--
-- Name: right_assignments; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE right_assignments (
    id uuid NOT NULL,
    rightname text NOT NULL,
    facilityid uuid,
    programid uuid,
    userid uuid NOT NULL
);


ALTER TABLE right_assignments OWNER TO postgres;

--
-- Name: right_attachments; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE right_attachments (
    rightid uuid NOT NULL,
    attachmentid uuid NOT NULL
);


ALTER TABLE right_attachments OWNER TO postgres;

--
-- Name: rights; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE rights (
    id uuid NOT NULL,
    description text,
    name text NOT NULL,
    type text NOT NULL
);


ALTER TABLE rights OWNER TO postgres;

--
-- Name: role_assignments; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE role_assignments (
    type character varying(31) NOT NULL,
    id uuid NOT NULL,
    roleid uuid,
    userid uuid,
    warehouseid uuid,
    programid uuid,
    supervisorynodeid uuid
);


ALTER TABLE role_assignments OWNER TO postgres;

--
-- Name: role_rights; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE role_rights (
    roleid uuid NOT NULL,
    rightid uuid NOT NULL
);


ALTER TABLE role_rights OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE roles (
    id uuid NOT NULL,
    description text,
    name text NOT NULL
);


ALTER TABLE roles OWNER TO postgres;

--
-- Name: schema_version; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE schema_version OWNER TO postgres;

--
-- Name: service_accounts; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE service_accounts (
    id uuid NOT NULL,
    createdby uuid NOT NULL,
    createddate timestamp with time zone NOT NULL
);


ALTER TABLE service_accounts OWNER TO postgres;

--
-- Name: stock_adjustment_reasons; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE stock_adjustment_reasons (
    id uuid NOT NULL,
    additive boolean,
    description text,
    displayorder integer,
    name text NOT NULL,
    programid uuid NOT NULL
);


ALTER TABLE stock_adjustment_reasons OWNER TO postgres;

--
-- Name: supervisory_nodes; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supervisory_nodes (
    id uuid NOT NULL,
    code text NOT NULL,
    description text,
    name text NOT NULL,
    facilityid uuid,
    parentid uuid
);


ALTER TABLE supervisory_nodes OWNER TO postgres;

--
-- Name: supply_lines; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supply_lines (
    id uuid NOT NULL,
    description text,
    programid uuid NOT NULL,
    supervisorynodeid uuid NOT NULL,
    supplyingfacilityid uuid NOT NULL
);


ALTER TABLE supply_lines OWNER TO postgres;

--
-- Name: supported_programs; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE supported_programs (
    active boolean NOT NULL,
    startdate date,
    facilityid uuid NOT NULL,
    programid uuid NOT NULL,
    locallyfulfilled boolean DEFAULT false NOT NULL
);


ALTER TABLE supported_programs OWNER TO postgres;

--
-- Name: trade_item_classifications; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE trade_item_classifications (
    id uuid NOT NULL,
    classificationsystem character varying(255) NOT NULL,
    classificationid character varying(255) NOT NULL,
    tradeitemid uuid NOT NULL
);


ALTER TABLE trade_item_classifications OWNER TO postgres;

--
-- Name: trade_items; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE trade_items (
    id uuid NOT NULL,
    manufactureroftradeitem character varying(255) NOT NULL,
    gtin text
);


ALTER TABLE trade_items OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: referencedata; Owner: postgres
--

CREATE TABLE users (
    id uuid NOT NULL,
    active boolean DEFAULT false NOT NULL,
    allownotify boolean DEFAULT true,
    email character varying(255),
    extradata jsonb,
    firstname text NOT NULL,
    lastname text NOT NULL,
    loginrestricted boolean DEFAULT false NOT NULL,
    timezone character varying(255),
    username text NOT NULL,
    verified boolean DEFAULT false NOT NULL,
    homefacilityid uuid,
    jobtitle character varying(255),
    phonenumber character varying(255)
);


ALTER TABLE users OWNER TO postgres;

SET search_path = report, pg_catalog;

--
-- Name: configuration_settings; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE configuration_settings (
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE configuration_settings OWNER TO postgres;

--
-- Name: data_loaded; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE data_loaded (
);


ALTER TABLE data_loaded OWNER TO postgres;

--
-- Name: jasper_template_parameter_dependencies; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE jasper_template_parameter_dependencies (
    id uuid NOT NULL,
    parameterid uuid NOT NULL,
    dependency text NOT NULL,
    placeholder text NOT NULL,
    property text NOT NULL
);


ALTER TABLE jasper_template_parameter_dependencies OWNER TO postgres;

--
-- Name: jasper_templates; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE jasper_templates (
    id uuid NOT NULL,
    data bytea,
    description text,
    name text NOT NULL,
    type text,
    visible boolean DEFAULT true
);


ALTER TABLE jasper_templates OWNER TO postgres;

--
-- Name: jasper_templates_report_images; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE jasper_templates_report_images (
    jaspertemplateid uuid NOT NULL,
    reportimageid uuid NOT NULL
);


ALTER TABLE jasper_templates_report_images OWNER TO postgres;

--
-- Name: jaspertemplate_requiredrights; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE jaspertemplate_requiredrights (
    jaspertemplateid uuid NOT NULL,
    requiredrights character varying(255)
);


ALTER TABLE jaspertemplate_requiredrights OWNER TO postgres;

--
-- Name: jaspertemplateparameter_options; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE jaspertemplateparameter_options (
    jaspertemplateparameterid uuid NOT NULL,
    options character varying(255)
);


ALTER TABLE jaspertemplateparameter_options OWNER TO postgres;

--
-- Name: jv_commit; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE jv_commit (
    commit_pk bigint NOT NULL,
    author character varying(200),
    commit_date timestamp without time zone,
    commit_id numeric(22,2)
);


ALTER TABLE jv_commit OWNER TO postgres;

--
-- Name: jv_commit_pk_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE jv_commit_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_commit_pk_seq OWNER TO postgres;

--
-- Name: jv_commit_property; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE jv_commit_property (
    property_name character varying(200) NOT NULL,
    property_value character varying(600),
    commit_fk bigint NOT NULL
);


ALTER TABLE jv_commit_property OWNER TO postgres;

--
-- Name: jv_global_id; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE jv_global_id (
    global_id_pk bigint NOT NULL,
    local_id character varying(200),
    fragment character varying(200),
    type_name character varying(200),
    owner_id_fk bigint
);


ALTER TABLE jv_global_id OWNER TO postgres;

--
-- Name: jv_global_id_pk_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE jv_global_id_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_global_id_pk_seq OWNER TO postgres;

--
-- Name: jv_snapshot; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE jv_snapshot (
    snapshot_pk bigint NOT NULL,
    type character varying(200),
    version bigint,
    state text,
    changed_properties text,
    managed_type character varying(200),
    global_id_fk bigint,
    commit_fk bigint
);


ALTER TABLE jv_snapshot OWNER TO postgres;

--
-- Name: jv_snapshot_pk_seq; Type: SEQUENCE; Schema: report; Owner: postgres
--

CREATE SEQUENCE jv_snapshot_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_snapshot_pk_seq OWNER TO postgres;

--
-- Name: report_images; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE report_images (
    id uuid NOT NULL,
    data bytea,
    name text NOT NULL
);


ALTER TABLE report_images OWNER TO postgres;

--
-- Name: schema_version; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE schema_version OWNER TO postgres;

--
-- Name: template_parameters; Type: TABLE; Schema: report; Owner: postgres
--

CREATE TABLE template_parameters (
    id uuid NOT NULL,
    datatype text,
    defaultvalue text,
    description text,
    displayname text,
    name text,
    selectexpression text,
    selectproperty text,
    displayproperty text,
    required boolean,
    templateid uuid NOT NULL,
    selectmethod text,
    selectbody text
);


ALTER TABLE template_parameters OWNER TO postgres;

SET search_path = requisition, pg_catalog;

--
-- Name: available_products; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE available_products (
    requisitionid uuid NOT NULL,
    value uuid
);


ALTER TABLE available_products OWNER TO postgres;

--
-- Name: available_requisition_column_options; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE available_requisition_column_options (
    id uuid NOT NULL,
    optionlabel character varying(255) NOT NULL,
    optionname character varying(255) NOT NULL,
    columnid uuid NOT NULL
);


ALTER TABLE available_requisition_column_options OWNER TO postgres;

--
-- Name: available_requisition_column_sources; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE available_requisition_column_sources (
    columnid uuid NOT NULL,
    value character varying(255)
);


ALTER TABLE available_requisition_column_sources OWNER TO postgres;

--
-- Name: available_requisition_columns; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE available_requisition_columns (
    id uuid NOT NULL,
    canbechangedbyuser boolean,
    canchangeorder boolean,
    columntype character varying(255) NOT NULL,
    definition text,
    indicator character varying(255),
    isdisplayrequired boolean,
    label character varying(255),
    mandatory boolean,
    name character varying(255),
    supportstag boolean DEFAULT false
);


ALTER TABLE available_requisition_columns OWNER TO postgres;

--
-- Name: columns_maps; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE columns_maps (
    requisitiontemplateid uuid NOT NULL,
    requisitioncolumnid uuid NOT NULL,
    definition text,
    displayorder integer NOT NULL,
    indicator character varying(255),
    isdisplayed boolean,
    label character varying(255),
    name character varying(255),
    requisitioncolumnoptionid uuid,
    source integer NOT NULL,
    key character varying(255) NOT NULL,
    tag character varying(255)
);


ALTER TABLE columns_maps OWNER TO postgres;

--
-- Name: configuration_settings; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE configuration_settings (
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE configuration_settings OWNER TO postgres;

--
-- Name: data_loaded; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE data_loaded (
);


ALTER TABLE data_loaded OWNER TO postgres;

--
-- Name: jasper_template_parameter_dependencies; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE jasper_template_parameter_dependencies (
    id uuid NOT NULL,
    parameterid uuid NOT NULL,
    dependency text NOT NULL,
    placeholder text NOT NULL
);


ALTER TABLE jasper_template_parameter_dependencies OWNER TO postgres;

--
-- Name: jasper_templates; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE jasper_templates (
    id uuid NOT NULL,
    data bytea,
    description text,
    name text NOT NULL,
    type text
);


ALTER TABLE jasper_templates OWNER TO postgres;

--
-- Name: jaspertemplateparameter_options; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE jaspertemplateparameter_options (
    jaspertemplateparameterid uuid NOT NULL,
    options character varying(255)
);


ALTER TABLE jaspertemplateparameter_options OWNER TO postgres;

--
-- Name: jv_commit; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE jv_commit (
    commit_pk bigint NOT NULL,
    author character varying(200),
    commit_date timestamp without time zone,
    commit_id numeric(22,2)
);


ALTER TABLE jv_commit OWNER TO postgres;

--
-- Name: jv_commit_pk_seq; Type: SEQUENCE; Schema: requisition; Owner: postgres
--

CREATE SEQUENCE jv_commit_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_commit_pk_seq OWNER TO postgres;

--
-- Name: jv_commit_property; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE jv_commit_property (
    property_name character varying(200) NOT NULL,
    property_value character varying(600),
    commit_fk bigint NOT NULL
);


ALTER TABLE jv_commit_property OWNER TO postgres;

--
-- Name: jv_global_id; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE jv_global_id (
    global_id_pk bigint NOT NULL,
    local_id character varying(200),
    fragment character varying(200),
    type_name character varying(200),
    owner_id_fk bigint
);


ALTER TABLE jv_global_id OWNER TO postgres;

--
-- Name: jv_global_id_pk_seq; Type: SEQUENCE; Schema: requisition; Owner: postgres
--

CREATE SEQUENCE jv_global_id_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_global_id_pk_seq OWNER TO postgres;

--
-- Name: jv_snapshot; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE jv_snapshot (
    snapshot_pk bigint NOT NULL,
    type character varying(200),
    version bigint,
    state text,
    changed_properties text,
    managed_type character varying(200),
    global_id_fk bigint,
    commit_fk bigint
);


ALTER TABLE jv_snapshot OWNER TO postgres;

--
-- Name: jv_snapshot_pk_seq; Type: SEQUENCE; Schema: requisition; Owner: postgres
--

CREATE SEQUENCE jv_snapshot_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jv_snapshot_pk_seq OWNER TO postgres;

--
-- Name: previous_adjusted_consumptions; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE previous_adjusted_consumptions (
    requisitionlineitemid uuid NOT NULL,
    previousadjustedconsumption integer
);


ALTER TABLE previous_adjusted_consumptions OWNER TO postgres;

--
-- Name: requisition_line_items; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE requisition_line_items (
    id uuid NOT NULL,
    adjustedconsumption integer,
    approvedquantity integer,
    averageconsumption integer,
    beginningbalance integer,
    calculatedorderquantity integer,
    maxperiodsofstock numeric(19,2),
    maximumstockquantity integer,
    nonfullsupply boolean NOT NULL,
    numberofnewpatientsadded integer,
    orderableid uuid,
    packstoship bigint,
    priceperpack numeric(19,2),
    remarks character varying(250),
    requestedquantity integer,
    requestedquantityexplanation character varying(255),
    skipped boolean,
    stockonhand integer,
    total integer,
    totalconsumedquantity integer,
    totalcost numeric(19,2),
    totallossesandadjustments integer,
    totalreceivedquantity integer,
    totalstockoutdays integer,
    requisitionid uuid,
    idealstockamount integer,
    calculatedorderquantityisa integer
);


ALTER TABLE requisition_line_items OWNER TO postgres;

--
-- Name: requisition_permission_strings; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE requisition_permission_strings (
    id uuid NOT NULL,
    requisitionid uuid NOT NULL,
    permissionstring text NOT NULL
);


ALTER TABLE requisition_permission_strings OWNER TO postgres;

--
-- Name: requisition_template_assignments; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE requisition_template_assignments (
    id uuid NOT NULL,
    programid uuid NOT NULL,
    facilitytypeid uuid,
    templateid uuid NOT NULL
);


ALTER TABLE requisition_template_assignments OWNER TO postgres;

--
-- Name: requisition_templates; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE requisition_templates (
    id uuid NOT NULL,
    createddate timestamp with time zone,
    modifieddate timestamp with time zone,
    numberofperiodstoaverage integer,
    programid uuid,
    populatestockonhandfromstockcards boolean DEFAULT false NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE requisition_templates OWNER TO postgres;

--
-- Name: requisitions; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE requisitions (
    id uuid NOT NULL,
    createddate timestamp with time zone,
    modifieddate timestamp with time zone,
    draftstatusmessage text,
    emergency boolean NOT NULL,
    facilityid uuid NOT NULL,
    numberofmonthsinperiod integer NOT NULL,
    processingperiodid uuid NOT NULL,
    programid uuid NOT NULL,
    status character varying(255) NOT NULL,
    supervisorynodeid uuid,
    supplyingfacilityid uuid,
    templateid uuid NOT NULL,
    datephysicalstockcountcompleted date,
    version bigint DEFAULT 0
);


ALTER TABLE requisitions OWNER TO postgres;

--
-- Name: requisitions_previous_requisitions; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE requisitions_previous_requisitions (
    requisitionid uuid NOT NULL,
    previousrequisitionid uuid NOT NULL
);


ALTER TABLE requisitions_previous_requisitions OWNER TO postgres;

--
-- Name: schema_version; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE schema_version OWNER TO postgres;

--
-- Name: status_changes; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE status_changes (
    id uuid NOT NULL,
    createddate timestamp with time zone,
    modifieddate timestamp with time zone,
    authorid uuid,
    status character varying(255) NOT NULL,
    requisitionid uuid NOT NULL,
    supervisorynodeid uuid
);


ALTER TABLE status_changes OWNER TO postgres;

--
-- Name: status_messages; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE status_messages (
    id uuid NOT NULL,
    createddate timestamp with time zone,
    modifieddate timestamp with time zone,
    authorfirstname character varying(255),
    authorid uuid,
    authorlastname character varying(255),
    body text NOT NULL,
    status character varying(255) NOT NULL,
    requisitionid uuid NOT NULL,
    statuschangeid uuid NOT NULL
);


ALTER TABLE status_messages OWNER TO postgres;

--
-- Name: stock_adjustment_reasons; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE stock_adjustment_reasons (
    id uuid NOT NULL,
    reasonid uuid NOT NULL,
    description text,
    isfreetextallowed boolean NOT NULL,
    name text NOT NULL,
    reasoncategory text NOT NULL,
    reasontype text NOT NULL,
    requisitionid uuid,
    hidden boolean
);


ALTER TABLE stock_adjustment_reasons OWNER TO postgres;

--
-- Name: stock_adjustments; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE stock_adjustments (
    id uuid NOT NULL,
    quantity integer NOT NULL,
    reasonid uuid NOT NULL,
    requisitionlineitemid uuid
);


ALTER TABLE stock_adjustments OWNER TO postgres;

--
-- Name: template_parameters; Type: TABLE; Schema: requisition; Owner: postgres
--

CREATE TABLE template_parameters (
    id uuid NOT NULL,
    datatype text,
    defaultvalue text,
    description text,
    displayname text,
    name text,
    selectexpression text,
    templateid uuid NOT NULL,
    selectproperty text,
    displayproperty text,
    required boolean,
    selectmethod text,
    selectbody text
);


ALTER TABLE template_parameters OWNER TO postgres;

SET search_path = stockmanagement, pg_catalog;

--
-- Name: available_stock_card_fields; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE available_stock_card_fields (
    id uuid NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE available_stock_card_fields OWNER TO postgres;

--
-- Name: available_stock_card_line_item_fields; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE available_stock_card_line_item_fields (
    id uuid NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE available_stock_card_line_item_fields OWNER TO postgres;

--
-- Name: jasper_templates; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE jasper_templates (
    id uuid NOT NULL,
    name text NOT NULL,
    data bytea,
    type text,
    description text
);


ALTER TABLE jasper_templates OWNER TO postgres;

--
-- Name: nodes; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE nodes (
    id uuid NOT NULL,
    isrefdatafacility boolean NOT NULL,
    referenceid uuid NOT NULL
);


ALTER TABLE nodes OWNER TO postgres;

--
-- Name: organizations; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE organizations (
    id uuid NOT NULL,
    name text NOT NULL
);


ALTER TABLE organizations OWNER TO postgres;

--
-- Name: physical_inventories; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE physical_inventories (
    id uuid NOT NULL,
    documentnumber character varying(255),
    facilityid uuid NOT NULL,
    isdraft boolean NOT NULL,
    occurreddate date,
    programid uuid NOT NULL,
    signature character varying(255),
    stockeventid uuid
);


ALTER TABLE physical_inventories OWNER TO postgres;

--
-- Name: physical_inventory_line_item_adjustments; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE physical_inventory_line_item_adjustments (
    id uuid NOT NULL,
    quantity integer NOT NULL,
    reasonid uuid NOT NULL,
    physicalinventorylineitemid uuid,
    stockcardlineitemid uuid,
    stockeventlineitemid uuid
);


ALTER TABLE physical_inventory_line_item_adjustments OWNER TO postgres;

--
-- Name: physical_inventory_line_items; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE physical_inventory_line_items (
    id uuid NOT NULL,
    lotid uuid,
    orderableid uuid NOT NULL,
    quantity integer,
    physicalinventoryid uuid NOT NULL,
    extradata jsonb,
    previousstockonhandwhensubmitted integer
);


ALTER TABLE physical_inventory_line_items OWNER TO postgres;

--
-- Name: schema_version; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE schema_version (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE schema_version OWNER TO postgres;

--
-- Name: stock_card_fields; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE stock_card_fields (
    id uuid NOT NULL,
    displayorder integer NOT NULL,
    isdisplayed boolean NOT NULL,
    availablestockcardfieldsid uuid,
    stockcardtemplateid uuid
);


ALTER TABLE stock_card_fields OWNER TO postgres;

--
-- Name: stock_card_line_item_fields; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE stock_card_line_item_fields (
    id uuid NOT NULL,
    displayorder integer NOT NULL,
    isdisplayed boolean NOT NULL,
    availablestockcardlineitemfieldsid uuid,
    stockcardtemplateid uuid
);


ALTER TABLE stock_card_line_item_fields OWNER TO postgres;

--
-- Name: stock_card_line_item_reason_tags; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE stock_card_line_item_reason_tags (
    tag character varying(255) NOT NULL,
    reasonid uuid NOT NULL
);


ALTER TABLE stock_card_line_item_reason_tags OWNER TO postgres;

--
-- Name: stock_card_line_item_reasons; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE stock_card_line_item_reasons (
    id uuid NOT NULL,
    description text,
    isfreetextallowed boolean NOT NULL,
    name text NOT NULL,
    reasoncategory text NOT NULL,
    reasontype text NOT NULL
);


ALTER TABLE stock_card_line_item_reasons OWNER TO postgres;

--
-- Name: stock_card_line_items; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE stock_card_line_items (
    id uuid NOT NULL,
    destinationfreetext character varying(255),
    documentnumber character varying(255),
    occurreddate date NOT NULL,
    processeddate timestamp without time zone NOT NULL,
    quantity integer NOT NULL,
    reasonfreetext character varying(255),
    signature character varying(255),
    sourcefreetext character varying(255),
    userid uuid NOT NULL,
    destinationid uuid,
    origineventid uuid NOT NULL,
    reasonid uuid,
    sourceid uuid,
    stockcardid uuid NOT NULL,
    extradata jsonb
);


ALTER TABLE stock_card_line_items OWNER TO postgres;

--
-- Name: stock_card_templates; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE stock_card_templates (
    id uuid NOT NULL,
    facilitytypeid uuid NOT NULL,
    programid uuid NOT NULL
);


ALTER TABLE stock_card_templates OWNER TO postgres;

--
-- Name: stock_cards; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE stock_cards (
    id uuid NOT NULL,
    facilityid uuid NOT NULL,
    lotid uuid,
    orderableid uuid NOT NULL,
    programid uuid NOT NULL,
    origineventid uuid NOT NULL
);


ALTER TABLE stock_cards OWNER TO postgres;

--
-- Name: stock_event_line_items; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE stock_event_line_items (
    id uuid NOT NULL,
    destinationfreetext character varying(255),
    destinationid uuid,
    lotid uuid,
    occurreddate date NOT NULL,
    orderableid uuid NOT NULL,
    quantity integer NOT NULL,
    reasonfreetext character varying(255),
    reasonid uuid,
    sourcefreetext character varying(255),
    sourceid uuid,
    stockeventid uuid NOT NULL,
    extradata jsonb
);


ALTER TABLE stock_event_line_items OWNER TO postgres;

--
-- Name: stock_events; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE stock_events (
    id uuid NOT NULL,
    documentnumber character varying(255),
    facilityid uuid NOT NULL,
    processeddate timestamp without time zone NOT NULL,
    programid uuid NOT NULL,
    signature character varying(255),
    userid uuid NOT NULL
);


ALTER TABLE stock_events OWNER TO postgres;

--
-- Name: valid_destination_assignments; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE valid_destination_assignments (
    id uuid NOT NULL,
    facilitytypeid uuid NOT NULL,
    programid uuid NOT NULL,
    nodeid uuid NOT NULL
);


ALTER TABLE valid_destination_assignments OWNER TO postgres;

--
-- Name: valid_reason_assignments; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE valid_reason_assignments (
    id uuid NOT NULL,
    facilitytypeid uuid NOT NULL,
    programid uuid NOT NULL,
    reasonid uuid NOT NULL,
    hidden boolean DEFAULT false NOT NULL
);


ALTER TABLE valid_reason_assignments OWNER TO postgres;

--
-- Name: valid_source_assignments; Type: TABLE; Schema: stockmanagement; Owner: postgres
--

CREATE TABLE valid_source_assignments (
    id uuid NOT NULL,
    facilitytypeid uuid NOT NULL,
    programid uuid NOT NULL,
    nodeid uuid NOT NULL
);


ALTER TABLE valid_source_assignments OWNER TO postgres;

SET search_path = auth, pg_catalog;

--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (token);


--
-- Name: auth_users auth_users_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY auth_users
    ADD CONSTRAINT auth_users_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_details oauth_client_details_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY oauth_client_details
    ADD CONSTRAINT oauth_client_details_pkey PRIMARY KEY (clientid);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (id);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: password_reset_tokens uk_la2ts67g4oh2sreayswhox1i6; Type: CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY password_reset_tokens
    ADD CONSTRAINT uk_la2ts67g4oh2sreayswhox1i6 UNIQUE (userid);


SET search_path = cce, pg_catalog;

--
-- Name: cce_alert_status_messages cce_alert_status_messages_pkey; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_alert_status_messages
    ADD CONSTRAINT cce_alert_status_messages_pkey PRIMARY KEY (alertid, locale);


--
-- Name: cce_alerts cce_alerts_externalid_key; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_alerts
    ADD CONSTRAINT cce_alerts_externalid_key UNIQUE (externalid);


--
-- Name: cce_alerts cce_alerts_pkey; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_alerts
    ADD CONSTRAINT cce_alerts_pkey PRIMARY KEY (id);


--
-- Name: cce_catalog_items cce_catalog_pkey; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_catalog_items
    ADD CONSTRAINT cce_catalog_pkey PRIMARY KEY (id);


--
-- Name: cce_inventory_items cce_inventory_pkey; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_inventory_items
    ADD CONSTRAINT cce_inventory_pkey PRIMARY KEY (id);


--
-- Name: jv_commit jv_commit_pk; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY jv_commit
    ADD CONSTRAINT jv_commit_pk PRIMARY KEY (commit_pk);


--
-- Name: jv_commit_property jv_commit_property_pk; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_pk PRIMARY KEY (commit_fk, property_name);


--
-- Name: jv_global_id jv_global_id_pk; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_pk PRIMARY KEY (global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_pk; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_pk PRIMARY KEY (snapshot_pk);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: cce_catalog_items unq_catalog_items_eqcode; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_catalog_items
    ADD CONSTRAINT unq_catalog_items_eqcode UNIQUE (equipmentcode, model);


--
-- Name: cce_catalog_items unq_catalog_items_man_model; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_catalog_items
    ADD CONSTRAINT unq_catalog_items_man_model UNIQUE (manufacturer, model);


--
-- Name: cce_inventory_items unq_inventory_catalog_eqid; Type: CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_inventory_items
    ADD CONSTRAINT unq_inventory_catalog_eqid UNIQUE (catalogitemid, equipmenttrackingid);


SET search_path = fulfillment, pg_catalog;

--
-- Name: configuration_settings configuration_settings_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY configuration_settings
    ADD CONSTRAINT configuration_settings_pkey PRIMARY KEY (key);


--
-- Name: jv_commit jv_commit_pk; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY jv_commit
    ADD CONSTRAINT jv_commit_pk PRIMARY KEY (commit_pk);


--
-- Name: jv_commit_property jv_commit_property_pk; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_pk PRIMARY KEY (commit_fk, property_name);


--
-- Name: jv_global_id jv_global_id_pk; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_pk PRIMARY KEY (global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_pk; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_pk PRIMARY KEY (snapshot_pk);


--
-- Name: order_file_columns order_file_columns_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY order_file_columns
    ADD CONSTRAINT order_file_columns_pkey PRIMARY KEY (id);


--
-- Name: order_file_templates order_file_templates_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY order_file_templates
    ADD CONSTRAINT order_file_templates_pkey PRIMARY KEY (id);


--
-- Name: order_line_items order_line_items_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY order_line_items
    ADD CONSTRAINT order_line_items_pkey PRIMARY KEY (id);


--
-- Name: order_number_configurations order_number_configurations_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY order_number_configurations
    ADD CONSTRAINT order_number_configurations_pkey PRIMARY KEY (id);


--
-- Name: orders orders_externalid_unique; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_externalid_unique UNIQUE (externalid);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: proof_of_delivery_line_items proof_of_delivery_line_items_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY proof_of_delivery_line_items
    ADD CONSTRAINT proof_of_delivery_line_items_pkey PRIMARY KEY (id);


--
-- Name: proofs_of_delivery proofs_of_delivery_key; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY proofs_of_delivery
    ADD CONSTRAINT proofs_of_delivery_key PRIMARY KEY (id);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: shipment_draft_line_items shipment_draft_line_items_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipment_draft_line_items
    ADD CONSTRAINT shipment_draft_line_items_pkey PRIMARY KEY (id);


--
-- Name: shipment_drafts shipment_drafts_orderid_unq; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipment_drafts
    ADD CONSTRAINT shipment_drafts_orderid_unq UNIQUE (orderid);


--
-- Name: shipment_drafts shipment_drafts_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipment_drafts
    ADD CONSTRAINT shipment_drafts_pkey PRIMARY KEY (id);


--
-- Name: shipment_line_items shipment_line_items_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipment_line_items
    ADD CONSTRAINT shipment_line_items_pkey PRIMARY KEY (id);


--
-- Name: shipments shipments_order_unq; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipments
    ADD CONSTRAINT shipments_order_unq UNIQUE (orderid);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);


--
-- Name: status_messages status_messages_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY status_messages
    ADD CONSTRAINT status_messages_pkey PRIMARY KEY (id);


--
-- Name: template_parameters template_parameters_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY template_parameters
    ADD CONSTRAINT template_parameters_pkey PRIMARY KEY (id);


--
-- Name: templates templates_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (id);


--
-- Name: transfer_properties transfer_properties_pkey; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY transfer_properties
    ADD CONSTRAINT transfer_properties_pkey PRIMARY KEY (id);


--
-- Name: templates uk_1nah70jfu9ck93htxiwym9c3b; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY templates
    ADD CONSTRAINT uk_1nah70jfu9ck93htxiwym9c3b UNIQUE (name);


--
-- Name: orders uk_21y81ilpcwtxc459g3l41nbli; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT uk_21y81ilpcwtxc459g3l41nbli UNIQUE (ordercode);


--
-- Name: transfer_properties uk_sprkvmtubsjd58jc0afdycmiy; Type: CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY transfer_properties
    ADD CONSTRAINT uk_sprkvmtubsjd58jc0afdycmiy UNIQUE (facilityid);


SET search_path = notification, pg_catalog;

--
-- Name: email_verification_tokens email_verification_tokens_pkey; Type: CONSTRAINT; Schema: notification; Owner: postgres
--

ALTER TABLE ONLY email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_pkey PRIMARY KEY (id);


--
-- Name: notification_messages notification_messages_pkey; Type: CONSTRAINT; Schema: notification; Owner: postgres
--

ALTER TABLE ONLY notification_messages
    ADD CONSTRAINT notification_messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: notification; Owner: postgres
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: notification; Owner: postgres
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: notification_messages unq_notification_messages_notificationid_channel; Type: CONSTRAINT; Schema: notification; Owner: postgres
--

ALTER TABLE ONLY notification_messages
    ADD CONSTRAINT unq_notification_messages_notificationid_channel UNIQUE (notificationid, channel);


--
-- Name: user_contact_details user_contact_details_pkey; Type: CONSTRAINT; Schema: notification; Owner: postgres
--

ALTER TABLE ONLY user_contact_details
    ADD CONSTRAINT user_contact_details_pkey PRIMARY KEY (referencedatauserid);


SET search_path = referencedata, pg_catalog;

--
-- Name: commodity_types commodity_types_classificationsystem_classificationid_key; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY commodity_types
    ADD CONSTRAINT commodity_types_classificationsystem_classificationid_key UNIQUE (classificationsystem, classificationid);


--
-- Name: commodity_types commodity_types_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY commodity_types
    ADD CONSTRAINT commodity_types_pkey PRIMARY KEY (id);


--
-- Name: dispensable_attributes dispensable_attributes_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY dispensable_attributes
    ADD CONSTRAINT dispensable_attributes_pkey PRIMARY KEY (dispensableid, key);


--
-- Name: dispensables dispensables_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY dispensables
    ADD CONSTRAINT dispensables_pkey PRIMARY KEY (id);


--
-- Name: facilities facilities_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT facilities_pkey PRIMARY KEY (id);


--
-- Name: facility_operators facility_operators_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facility_operators
    ADD CONSTRAINT facility_operators_pkey PRIMARY KEY (id);


--
-- Name: facility_type_approved_products facility_type_approved_products_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facility_type_approved_products
    ADD CONSTRAINT facility_type_approved_products_pkey PRIMARY KEY (id);


--
-- Name: facility_types facility_types_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facility_types
    ADD CONSTRAINT facility_types_pkey PRIMARY KEY (id);


--
-- Name: geographic_levels geographic_levels_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY geographic_levels
    ADD CONSTRAINT geographic_levels_pkey PRIMARY KEY (id);


--
-- Name: geographic_zones geographic_zones_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY geographic_zones
    ADD CONSTRAINT geographic_zones_pkey PRIMARY KEY (id);


--
-- Name: ideal_stock_amounts ideal_stock_amounts_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY ideal_stock_amounts
    ADD CONSTRAINT ideal_stock_amounts_pkey PRIMARY KEY (id);


--
-- Name: jv_commit jv_commit_pk; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY jv_commit
    ADD CONSTRAINT jv_commit_pk PRIMARY KEY (commit_pk);


--
-- Name: jv_commit_property jv_commit_property_pk; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_pk PRIMARY KEY (commit_fk, property_name);


--
-- Name: jv_global_id jv_global_id_pk; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_pk PRIMARY KEY (global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_pk; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_pk PRIMARY KEY (snapshot_pk);


--
-- Name: lots lots_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY lots
    ADD CONSTRAINT lots_pkey PRIMARY KEY (id);


--
-- Name: orderable_display_categories orderable_display_categories_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY orderable_display_categories
    ADD CONSTRAINT orderable_display_categories_pkey PRIMARY KEY (id);


--
-- Name: orderable_identifiers orderable_identifiers_key_orderableid_key; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY orderable_identifiers
    ADD CONSTRAINT orderable_identifiers_key_orderableid_key UNIQUE (key, orderableid);


--
-- Name: orderables orderables_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY orderables
    ADD CONSTRAINT orderables_pkey PRIMARY KEY (id);


--
-- Name: right_assignments permission_strings_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY right_assignments
    ADD CONSTRAINT permission_strings_pkey PRIMARY KEY (id);


--
-- Name: processing_periods processing_periods_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY processing_periods
    ADD CONSTRAINT processing_periods_pkey PRIMARY KEY (id);


--
-- Name: processing_schedules processing_schedules_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY processing_schedules
    ADD CONSTRAINT processing_schedules_pkey PRIMARY KEY (id);


--
-- Name: program_orderables program_orderables_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY program_orderables
    ADD CONSTRAINT program_orderables_pkey PRIMARY KEY (id);


--
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- Name: requisition_group_members requisition_group_members_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_group_members
    ADD CONSTRAINT requisition_group_members_pkey PRIMARY KEY (requisitiongroupid, facilityid);


--
-- Name: requisition_group_program_schedules requisition_group_program_schedule_unique_program_requisitiongr; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_schedule_unique_program_requisitiongr UNIQUE (requisitiongroupid, programid) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: requisition_group_program_schedules requisition_group_program_schedules_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT requisition_group_program_schedules_pkey PRIMARY KEY (id);


--
-- Name: requisition_groups requisition_groups_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_groups
    ADD CONSTRAINT requisition_groups_pkey PRIMARY KEY (id);


--
-- Name: right_attachments right_attachments_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY right_attachments
    ADD CONSTRAINT right_attachments_pkey PRIMARY KEY (rightid, attachmentid);


--
-- Name: rights rights_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY rights
    ADD CONSTRAINT rights_pkey PRIMARY KEY (id);


--
-- Name: role_assignments role_assignments_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT role_assignments_pkey PRIMARY KEY (id);


--
-- Name: role_rights role_rights_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY role_rights
    ADD CONSTRAINT role_rights_pkey PRIMARY KEY (roleid, rightid);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: service_accounts service_accounts_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY service_accounts
    ADD CONSTRAINT service_accounts_pkey PRIMARY KEY (id);


--
-- Name: stock_adjustment_reasons stock_adjustment_reasons_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY stock_adjustment_reasons
    ADD CONSTRAINT stock_adjustment_reasons_pkey PRIMARY KEY (id);


--
-- Name: supervisory_nodes supervisory_nodes_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supervisory_nodes
    ADD CONSTRAINT supervisory_nodes_pkey PRIMARY KEY (id);


--
-- Name: supply_lines supply_line_unique_program_supervisory_node; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT supply_line_unique_program_supervisory_node UNIQUE (supervisorynodeid, programid);


--
-- Name: supply_lines supply_lines_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT supply_lines_pkey PRIMARY KEY (id);


--
-- Name: supported_programs supported_programs_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supported_programs
    ADD CONSTRAINT supported_programs_pkey PRIMARY KEY (facilityid, programid);


--
-- Name: trade_items trade_items_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY trade_items
    ADD CONSTRAINT trade_items_pkey PRIMARY KEY (id);


--
-- Name: rights uk_4f64k9vkx833wfpw8n25x2602; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY rights
    ADD CONSTRAINT uk_4f64k9vkx833wfpw8n25x2602 UNIQUE (name);


--
-- Name: users uk_6dotkott2kjsp8vw4d0m25fb7; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT uk_6dotkott2kjsp8vw4d0m25fb7 UNIQUE (email);


--
-- Name: supervisory_nodes uk_9vforn7hxhuinr8bmu0vkad3v; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supervisory_nodes
    ADD CONSTRAINT uk_9vforn7hxhuinr8bmu0vkad3v UNIQUE (code);


--
-- Name: geographic_levels uk_by9o3bl6rafeuane589514s2v; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY geographic_levels
    ADD CONSTRAINT uk_by9o3bl6rafeuane589514s2v UNIQUE (code);


--
-- Name: facility_operators uk_g7ooo22v3vokh2qrqbxw7uaps; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facility_operators
    ADD CONSTRAINT uk_g7ooo22v3vokh2qrqbxw7uaps UNIQUE (code);


--
-- Name: geographic_zones uk_jpns3ahywgm4k52rdfm08m9k0; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY geographic_zones
    ADD CONSTRAINT uk_jpns3ahywgm4k52rdfm08m9k0 UNIQUE (code);


--
-- Name: facilities uk_mnsci7u7h2r2b3tohhn0b819; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT uk_mnsci7u7h2r2b3tohhn0b819 UNIQUE (code);


--
-- Name: requisition_groups uk_nrqjt84p9wmrm1qmr7nokj8sg; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_groups
    ADD CONSTRAINT uk_nrqjt84p9wmrm1qmr7nokj8sg UNIQUE (code);


--
-- Name: roles uk_ofx66keruapi6vyqpv6f2or37; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT uk_ofx66keruapi6vyqpv6f2or37 UNIQUE (name);


--
-- Name: trade_items uk_tradeitems_gtin; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY trade_items
    ADD CONSTRAINT uk_tradeitems_gtin UNIQUE (gtin);


--
-- Name: facility_type_approved_products unq_ftap; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facility_type_approved_products
    ADD CONSTRAINT unq_ftap UNIQUE (facilitytypeid, orderableid, programid);


--
-- Name: orderables unq_productcode; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY orderables
    ADD CONSTRAINT unq_productcode UNIQUE (code);


--
-- Name: programs unq_program_code; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY programs
    ADD CONSTRAINT unq_program_code UNIQUE (code);


--
-- Name: trade_item_classifications unq_trade_item_classifications_system; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY trade_item_classifications
    ADD CONSTRAINT unq_trade_item_classifications_system UNIQUE (tradeitemid, classificationsystem);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


SET search_path = report, pg_catalog;

--
-- Name: configuration_settings configuration_settings_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY configuration_settings
    ADD CONSTRAINT configuration_settings_pkey PRIMARY KEY (key);


--
-- Name: jasper_templates jasper_templates_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jasper_templates
    ADD CONSTRAINT jasper_templates_pkey PRIMARY KEY (id);


--
-- Name: jv_commit jv_commit_pk; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jv_commit
    ADD CONSTRAINT jv_commit_pk PRIMARY KEY (commit_pk);


--
-- Name: jv_commit_property jv_commit_property_pk; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_pk PRIMARY KEY (commit_fk, property_name);


--
-- Name: jv_global_id jv_global_id_pk; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_pk PRIMARY KEY (global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_pk; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_pk PRIMARY KEY (snapshot_pk);


--
-- Name: report_images report_images_name_uk; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY report_images
    ADD CONSTRAINT report_images_name_uk UNIQUE (name);


--
-- Name: report_images report_images_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY report_images
    ADD CONSTRAINT report_images_pkey PRIMARY KEY (id);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: template_parameters template_parameters_pkey; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY template_parameters
    ADD CONSTRAINT template_parameters_pkey PRIMARY KEY (id);


--
-- Name: jasper_templates uk_5878s5vb2v4y53vun95nrdvgw; Type: CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jasper_templates
    ADD CONSTRAINT uk_5878s5vb2v4y53vun95nrdvgw UNIQUE (name);


SET search_path = requisition, pg_catalog;

--
-- Name: available_requisition_column_options available_requisition_column_options_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY available_requisition_column_options
    ADD CONSTRAINT available_requisition_column_options_pkey PRIMARY KEY (id);


--
-- Name: available_requisition_columns available_requisition_columns_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY available_requisition_columns
    ADD CONSTRAINT available_requisition_columns_pkey PRIMARY KEY (id);


--
-- Name: columns_maps columns_maps_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY columns_maps
    ADD CONSTRAINT columns_maps_pkey PRIMARY KEY (requisitiontemplateid, key);


--
-- Name: configuration_settings configuration_settings_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY configuration_settings
    ADD CONSTRAINT configuration_settings_pkey PRIMARY KEY (key);


--
-- Name: jasper_templates jasper_templates_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jasper_templates
    ADD CONSTRAINT jasper_templates_pkey PRIMARY KEY (id);


--
-- Name: jv_commit jv_commit_pk; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jv_commit
    ADD CONSTRAINT jv_commit_pk PRIMARY KEY (commit_pk);


--
-- Name: jv_commit_property jv_commit_property_pk; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_pk PRIMARY KEY (commit_fk, property_name);


--
-- Name: jv_global_id jv_global_id_pk; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_pk PRIMARY KEY (global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_pk; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_pk PRIMARY KEY (snapshot_pk);


--
-- Name: requisition_line_items requisition_line_items_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisition_line_items
    ADD CONSTRAINT requisition_line_items_pkey PRIMARY KEY (id);


--
-- Name: requisition_permission_strings requisition_permission_strings_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisition_permission_strings
    ADD CONSTRAINT requisition_permission_strings_pkey PRIMARY KEY (id);


--
-- Name: requisition_template_assignments requisition_template_assignments_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisition_template_assignments
    ADD CONSTRAINT requisition_template_assignments_pkey PRIMARY KEY (id);


--
-- Name: requisition_templates requisition_templates_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisition_templates
    ADD CONSTRAINT requisition_templates_pkey PRIMARY KEY (id);


--
-- Name: requisitions requisitions_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT requisitions_pkey PRIMARY KEY (id);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: status_messages status_change_id_unique; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY status_messages
    ADD CONSTRAINT status_change_id_unique UNIQUE (statuschangeid) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: status_changes status_changes_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY status_changes
    ADD CONSTRAINT status_changes_pkey PRIMARY KEY (id);


--
-- Name: status_messages status_messages_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY status_messages
    ADD CONSTRAINT status_messages_pkey PRIMARY KEY (id);


--
-- Name: stock_adjustment_reasons stock_adjustment_reasons_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY stock_adjustment_reasons
    ADD CONSTRAINT stock_adjustment_reasons_pkey PRIMARY KEY (id);


--
-- Name: stock_adjustments stock_adjustments_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY stock_adjustments
    ADD CONSTRAINT stock_adjustments_pkey PRIMARY KEY (id);


--
-- Name: template_parameters template_parameters_pkey; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY template_parameters
    ADD CONSTRAINT template_parameters_pkey PRIMARY KEY (id);


--
-- Name: jasper_templates uk_5878s5vb2v4y53vun95nrdvgw; Type: CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jasper_templates
    ADD CONSTRAINT uk_5878s5vb2v4y53vun95nrdvgw UNIQUE (name);


SET search_path = stockmanagement, pg_catalog;

--
-- Name: available_stock_card_fields available_stock_card_fields_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY available_stock_card_fields
    ADD CONSTRAINT available_stock_card_fields_pkey PRIMARY KEY (id);


--
-- Name: available_stock_card_line_item_fields available_stock_card_line_item_fields_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY available_stock_card_line_item_fields
    ADD CONSTRAINT available_stock_card_line_item_fields_pkey PRIMARY KEY (id);


--
-- Name: nodes nodes_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY nodes
    ADD CONSTRAINT nodes_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: physical_inventories physical_inventories_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY physical_inventories
    ADD CONSTRAINT physical_inventories_pkey PRIMARY KEY (id);


--
-- Name: physical_inventory_line_item_adjustments physical_inventory_line_item_adjustments_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY physical_inventory_line_item_adjustments
    ADD CONSTRAINT physical_inventory_line_item_adjustments_pkey PRIMARY KEY (id);


--
-- Name: physical_inventory_line_items physical_inventory_line_items_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY physical_inventory_line_items
    ADD CONSTRAINT physical_inventory_line_items_pkey PRIMARY KEY (id);


--
-- Name: schema_version schema_version_pk; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY schema_version
    ADD CONSTRAINT schema_version_pk PRIMARY KEY (installed_rank);


--
-- Name: stock_card_fields stock_card_fields_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_fields
    ADD CONSTRAINT stock_card_fields_pkey PRIMARY KEY (id);


--
-- Name: stock_card_line_item_fields stock_card_line_item_fields_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_item_fields
    ADD CONSTRAINT stock_card_line_item_fields_pkey PRIMARY KEY (id);


--
-- Name: stock_card_line_item_reasons stock_card_line_item_reasons_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_item_reasons
    ADD CONSTRAINT stock_card_line_item_reasons_pkey PRIMARY KEY (id);


--
-- Name: stock_card_line_items stock_card_line_items_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_items
    ADD CONSTRAINT stock_card_line_items_pkey PRIMARY KEY (id);


--
-- Name: stock_card_templates stock_card_templates_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_templates
    ADD CONSTRAINT stock_card_templates_pkey PRIMARY KEY (id);


--
-- Name: stock_cards stock_cards_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_cards
    ADD CONSTRAINT stock_cards_pkey PRIMARY KEY (id);


--
-- Name: stock_event_line_items stock_event_line_items_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_event_line_items
    ADD CONSTRAINT stock_event_line_items_pkey PRIMARY KEY (id);


--
-- Name: stock_events stock_events_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_events
    ADD CONSTRAINT stock_events_pkey PRIMARY KEY (id);


--
-- Name: valid_reason_assignments unq_valid_reasons; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY valid_reason_assignments
    ADD CONSTRAINT unq_valid_reasons UNIQUE (facilitytypeid, programid, reasonid);


--
-- Name: valid_destination_assignments valid_destination_assignments_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY valid_destination_assignments
    ADD CONSTRAINT valid_destination_assignments_pkey PRIMARY KEY (id);


--
-- Name: valid_reason_assignments valid_reason_assignments_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY valid_reason_assignments
    ADD CONSTRAINT valid_reason_assignments_pkey PRIMARY KEY (id);


--
-- Name: valid_source_assignments valid_source_assignments_pkey; Type: CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY valid_source_assignments
    ADD CONSTRAINT valid_source_assignments_pkey PRIMARY KEY (id);


SET search_path = auth, pg_catalog;

--
-- Name: schema_version_s_idx; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE INDEX schema_version_s_idx ON schema_version USING btree (success);


--
-- Name: username_unq_idx; Type: INDEX; Schema: auth; Owner: postgres
--

CREATE UNIQUE INDEX username_unq_idx ON auth_users USING btree (lower((username)::text));


SET search_path = cce, pg_catalog;

--
-- Name: cce_alerts_inventoryitemid_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX cce_alerts_inventoryitemid_idx ON cce_alerts USING btree (inventoryitemid);


--
-- Name: cce_inventory_items_catalogitemid_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX cce_inventory_items_catalogitemid_idx ON cce_inventory_items USING btree (catalogitemid);


--
-- Name: cce_inventory_items_facilityid_programid_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX cce_inventory_items_facilityid_programid_idx ON cce_inventory_items USING btree (facilityid, programid);


--
-- Name: jv_commit_commit_id_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX jv_commit_commit_id_idx ON jv_commit USING btree (commit_id);


--
-- Name: jv_commit_property_commit_fk_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX jv_commit_property_commit_fk_idx ON jv_commit_property USING btree (commit_fk);


--
-- Name: jv_commit_property_property_name_property_value_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX jv_commit_property_property_name_property_value_idx ON jv_commit_property USING btree (property_name, property_value);


--
-- Name: jv_global_id_local_id_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX jv_global_id_local_id_idx ON jv_global_id USING btree (local_id);


--
-- Name: jv_snapshot_commit_fk_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX jv_snapshot_commit_fk_idx ON jv_snapshot USING btree (commit_fk);


--
-- Name: jv_snapshot_global_id_fk_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX jv_snapshot_global_id_fk_idx ON jv_snapshot USING btree (global_id_fk);


--
-- Name: schema_version_s_idx; Type: INDEX; Schema: cce; Owner: postgres
--

CREATE INDEX schema_version_s_idx ON schema_version USING btree (success);


SET search_path = fulfillment, pg_catalog;

--
-- Name: jv_commit_commit_id_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX jv_commit_commit_id_idx ON jv_commit USING btree (commit_id);


--
-- Name: jv_commit_property_commit_fk_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX jv_commit_property_commit_fk_idx ON jv_commit_property USING btree (commit_fk);


--
-- Name: jv_commit_property_property_name_property_value_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX jv_commit_property_property_name_property_value_idx ON jv_commit_property USING btree (property_name, property_value);


--
-- Name: jv_global_id_local_id_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX jv_global_id_local_id_idx ON jv_global_id USING btree (local_id);


--
-- Name: jv_snapshot_commit_fk_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX jv_snapshot_commit_fk_idx ON jv_snapshot USING btree (commit_fk);


--
-- Name: jv_snapshot_global_id_fk_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX jv_snapshot_global_id_fk_idx ON jv_snapshot USING btree (global_id_fk);


--
-- Name: order_file_columns_orderfiletemplateid_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX order_file_columns_orderfiletemplateid_idx ON order_file_columns USING btree (orderfiletemplateid);


--
-- Name: order_line_items_orderid_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX order_line_items_orderid_idx ON order_line_items USING btree (orderid);


--
-- Name: proof_of_delivery_line_items_proofofdeliveryid_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX proof_of_delivery_line_items_proofofdeliveryid_idx ON proof_of_delivery_line_items USING btree (proofofdeliveryid);


--
-- Name: proofs_of_delivery_shipmentid_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX proofs_of_delivery_shipmentid_idx ON proofs_of_delivery USING btree (shipmentid);


--
-- Name: schema_version_s_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX schema_version_s_idx ON schema_version USING btree (success);


--
-- Name: shipment_draft_line_items_shipmentdraftid_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX shipment_draft_line_items_shipmentdraftid_idx ON shipment_draft_line_items USING btree (shipmentdraftid);

ALTER TABLE shipment_draft_line_items CLUSTER ON shipment_draft_line_items_shipmentdraftid_idx;


--
-- Name: shipment_line_items_shipmentid_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX shipment_line_items_shipmentid_idx ON shipment_line_items USING btree (shipmentid);

ALTER TABLE shipment_line_items CLUSTER ON shipment_line_items_shipmentid_idx;


--
-- Name: status_changes_orderid_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX status_changes_orderid_idx ON status_changes USING btree (orderid);


--
-- Name: status_messages_orderid_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX status_messages_orderid_idx ON status_messages USING btree (orderid);


--
-- Name: template_parameters_templateid_idx; Type: INDEX; Schema: fulfillment; Owner: postgres
--

CREATE INDEX template_parameters_templateid_idx ON template_parameters USING btree (templateid);


SET search_path = notification, pg_catalog;

--
-- Name: notifications_userid_idx; Type: INDEX; Schema: notification; Owner: postgres
--

CREATE INDEX notifications_userid_idx ON notifications USING btree (userid);


--
-- Name: schema_version_s_idx; Type: INDEX; Schema: notification; Owner: postgres
--

CREATE INDEX schema_version_s_idx ON schema_version USING btree (success);


--
-- Name: unq_contact_details_email; Type: INDEX; Schema: notification; Owner: postgres
--

CREATE UNIQUE INDEX unq_contact_details_email ON user_contact_details USING btree (email);


--
-- Name: unq_email_verification_tokens_emailaddress; Type: INDEX; Schema: notification; Owner: postgres
--

CREATE UNIQUE INDEX unq_email_verification_tokens_emailaddress ON email_verification_tokens USING btree (emailaddress);


--
-- Name: unq_email_verification_tokens_usercontactdetailsid; Type: INDEX; Schema: notification; Owner: postgres
--

CREATE UNIQUE INDEX unq_email_verification_tokens_usercontactdetailsid ON email_verification_tokens USING btree (usercontactdetailsid);


SET search_path = referencedata, pg_catalog;

--
-- Name: facilities_geographiczoneid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX facilities_geographiczoneid_idx ON facilities USING btree (geographiczoneid);


--
-- Name: facilities_location_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX facilities_location_idx ON facilities USING gist (location);


--
-- Name: facilities_operatedbyid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX facilities_operatedbyid_idx ON facilities USING btree (operatedbyid);


--
-- Name: facilities_typeid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX facilities_typeid_idx ON facilities USING btree (typeid);


--
-- Name: facility_type_approved_products_facilitytypeid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX facility_type_approved_products_facilitytypeid_idx ON facility_type_approved_products USING btree (facilitytypeid);


--
-- Name: facility_type_approved_products_orderableid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX facility_type_approved_products_orderableid_idx ON facility_type_approved_products USING btree (orderableid);


--
-- Name: facility_type_approved_products_programid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX facility_type_approved_products_programid_idx ON facility_type_approved_products USING btree (programid);


--
-- Name: ideal_stock_amounts_commoditytypeid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX ideal_stock_amounts_commoditytypeid_idx ON ideal_stock_amounts USING btree (commoditytypeid);


--
-- Name: ideal_stock_amounts_facilityid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX ideal_stock_amounts_facilityid_idx ON ideal_stock_amounts USING btree (facilityid);


--
-- Name: ideal_stock_amounts_processingperiodid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX ideal_stock_amounts_processingperiodid_idx ON ideal_stock_amounts USING btree (processingperiodid);


--
-- Name: jv_commit_commit_id_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX jv_commit_commit_id_idx ON jv_commit USING btree (commit_id);


--
-- Name: jv_commit_property_commit_fk_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX jv_commit_property_commit_fk_idx ON jv_commit_property USING btree (commit_fk);


--
-- Name: jv_commit_property_property_name_property_value_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX jv_commit_property_property_name_property_value_idx ON jv_commit_property USING btree (property_name, property_value);


--
-- Name: jv_global_id_local_id_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX jv_global_id_local_id_idx ON jv_global_id USING btree (local_id);


--
-- Name: jv_snapshot_commit_fk_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX jv_snapshot_commit_fk_idx ON jv_snapshot USING btree (commit_fk);


--
-- Name: jv_snapshot_global_id_fk_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX jv_snapshot_global_id_fk_idx ON jv_snapshot USING btree (global_id_fk);


--
-- Name: orderables_fullproductname_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX orderables_fullproductname_idx ON orderables USING btree (fullproductname);


--
-- Name: processing_schedule_code_unique_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE UNIQUE INDEX processing_schedule_code_unique_idx ON processing_schedules USING btree (lower(code));


--
-- Name: processing_schedule_name_unique_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE UNIQUE INDEX processing_schedule_name_unique_idx ON processing_schedules USING btree (lower(name));


--
-- Name: program_orderables_orderabledisplaycategoryid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX program_orderables_orderabledisplaycategoryid_idx ON program_orderables USING btree (orderabledisplaycategoryid);


--
-- Name: program_orderables_orderableid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX program_orderables_orderableid_idx ON program_orderables USING btree (orderableid);


--
-- Name: program_orderables_orderableid_idx1; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX program_orderables_orderableid_idx1 ON program_orderables USING btree (orderableid);


--
-- Name: program_orderables_programid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX program_orderables_programid_idx ON program_orderables USING btree (programid);


--
-- Name: right_assignments_programid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX right_assignments_programid_idx ON right_assignments USING btree (programid);


--
-- Name: right_assignments_userid_rightname_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX right_assignments_userid_rightname_idx ON right_assignments USING btree (userid, rightname);


--
-- Name: role_assignments_userid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX role_assignments_userid_idx ON role_assignments USING btree (userid);


--
-- Name: schema_version_s_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX schema_version_s_idx ON schema_version USING btree (success);


--
-- Name: supervisory_nodes_parentid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX supervisory_nodes_parentid_idx ON supervisory_nodes USING btree (parentid);


--
-- Name: supported_programs_facilityid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX supported_programs_facilityid_idx ON supported_programs USING btree (facilityid);


--
-- Name: supported_programs_programid_idx; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE INDEX supported_programs_programid_idx ON supported_programs USING btree (programid);


--
-- Name: unq_facility_type_code; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE UNIQUE INDEX unq_facility_type_code ON facility_types USING btree (lower(code));


--
-- Name: unq_orderableid_programid; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE UNIQUE INDEX unq_orderableid_programid ON program_orderables USING btree (orderableid, programid) WHERE (active = true);


--
-- Name: unq_username; Type: INDEX; Schema: referencedata; Owner: postgres
--

CREATE UNIQUE INDEX unq_username ON users USING btree (lower(username));


SET search_path = report, pg_catalog;

--
-- Name: jv_commit_commit_id_idx; Type: INDEX; Schema: report; Owner: postgres
--

CREATE INDEX jv_commit_commit_id_idx ON jv_commit USING btree (commit_id);


--
-- Name: jv_commit_property_commit_fk_idx; Type: INDEX; Schema: report; Owner: postgres
--

CREATE INDEX jv_commit_property_commit_fk_idx ON jv_commit_property USING btree (commit_fk);


--
-- Name: jv_commit_property_property_name_property_value_idx; Type: INDEX; Schema: report; Owner: postgres
--

CREATE INDEX jv_commit_property_property_name_property_value_idx ON jv_commit_property USING btree (property_name, property_value);


--
-- Name: jv_global_id_local_id_idx; Type: INDEX; Schema: report; Owner: postgres
--

CREATE INDEX jv_global_id_local_id_idx ON jv_global_id USING btree (local_id);


--
-- Name: jv_snapshot_commit_fk_idx; Type: INDEX; Schema: report; Owner: postgres
--

CREATE INDEX jv_snapshot_commit_fk_idx ON jv_snapshot USING btree (commit_fk);


--
-- Name: jv_snapshot_global_id_fk_idx; Type: INDEX; Schema: report; Owner: postgres
--

CREATE INDEX jv_snapshot_global_id_fk_idx ON jv_snapshot USING btree (global_id_fk);


--
-- Name: schema_version_s_idx; Type: INDEX; Schema: report; Owner: postgres
--

CREATE INDEX schema_version_s_idx ON schema_version USING btree (success);


SET search_path = requisition, pg_catalog;

--
-- Name: available_non_full_supply_products_requisitionid_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX available_non_full_supply_products_requisitionid_idx ON available_products USING btree (requisitionid);


--
-- Name: jv_commit_commit_id_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX jv_commit_commit_id_idx ON jv_commit USING btree (commit_id);


--
-- Name: jv_commit_property_commit_fk_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX jv_commit_property_commit_fk_idx ON jv_commit_property USING btree (commit_fk);


--
-- Name: jv_commit_property_property_name_property_value_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX jv_commit_property_property_name_property_value_idx ON jv_commit_property USING btree (property_name, property_value);


--
-- Name: jv_global_id_local_id_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX jv_global_id_local_id_idx ON jv_global_id USING btree (local_id);


--
-- Name: jv_snapshot_commit_fk_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX jv_snapshot_commit_fk_idx ON jv_snapshot USING btree (commit_fk);


--
-- Name: jv_snapshot_global_id_fk_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX jv_snapshot_global_id_fk_idx ON jv_snapshot USING btree (global_id_fk);


--
-- Name: previous_adjusted_consumptions_requisitionlineitemid_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX previous_adjusted_consumptions_requisitionlineitemid_idx ON previous_adjusted_consumptions USING btree (requisitionlineitemid);


--
-- Name: req_line_reason; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE UNIQUE INDEX req_line_reason ON stock_adjustments USING btree (reasonid, requisitionlineitemid);


--
-- Name: req_prod_fac_per; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE UNIQUE INDEX req_prod_fac_per ON requisitions USING btree (programid, facilityid, processingperiodid) WHERE (emergency = false);


--
-- Name: req_tmpl_asgmt_prog_fac_type_tmpl_unique_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE UNIQUE INDEX req_tmpl_asgmt_prog_fac_type_tmpl_unique_idx ON requisition_template_assignments USING btree (facilitytypeid, programid, templateid) WHERE (facilitytypeid IS NOT NULL);


--
-- Name: req_tmpl_asgmt_prog_fac_type_unique_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE UNIQUE INDEX req_tmpl_asgmt_prog_fac_type_unique_idx ON requisition_template_assignments USING btree (facilitytypeid, programid) WHERE (facilitytypeid IS NOT NULL);


--
-- Name: req_tmpl_asgmt_prog_tmpl_unique_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE UNIQUE INDEX req_tmpl_asgmt_prog_tmpl_unique_idx ON requisition_template_assignments USING btree (programid, templateid) WHERE (facilitytypeid IS NULL);


--
-- Name: requisition_line_items_requisitionid_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX requisition_line_items_requisitionid_idx ON requisition_line_items USING btree (requisitionid);

ALTER TABLE requisition_line_items CLUSTER ON requisition_line_items_requisitionid_idx;


--
-- Name: requisition_permission_strings_requisitionid_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX requisition_permission_strings_requisitionid_idx ON requisition_permission_strings USING btree (requisitionid);


--
-- Name: requisition_template_name_unique_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE UNIQUE INDEX requisition_template_name_unique_idx ON requisition_templates USING btree (name, archived) WHERE (archived IS FALSE);


--
-- Name: requisitions_previous_requisitions_requisitionid_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX requisitions_previous_requisitions_requisitionid_idx ON requisitions_previous_requisitions USING btree (requisitionid);


--
-- Name: schema_version_s_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX schema_version_s_idx ON schema_version USING btree (success);


--
-- Name: status_changes_requisitionid_idx; Type: INDEX; Schema: requisition; Owner: postgres
--

CREATE INDEX status_changes_requisitionid_idx ON status_changes USING btree (requisitionid);


SET search_path = stockmanagement, pg_catalog;

--
-- Name: idxn1cmkkm4m6eseyofm6789vic8; Type: INDEX; Schema: stockmanagement; Owner: postgres
--

CREATE INDEX idxn1cmkkm4m6eseyofm6789vic8 ON stock_cards USING btree (facilityid, programid, orderableid);


--
-- Name: physical_inventory_line_items_physicalinventoryid_idx; Type: INDEX; Schema: stockmanagement; Owner: postgres
--

CREATE INDEX physical_inventory_line_items_physicalinventoryid_idx ON physical_inventory_line_items USING btree (physicalinventoryid);


--
-- Name: schema_version_s_idx; Type: INDEX; Schema: stockmanagement; Owner: postgres
--

CREATE INDEX schema_version_s_idx ON schema_version USING btree (success);


--
-- Name: stock_card_line_item_reason_tags_unique_idx; Type: INDEX; Schema: stockmanagement; Owner: postgres
--

CREATE UNIQUE INDEX stock_card_line_item_reason_tags_unique_idx ON stock_card_line_item_reason_tags USING btree (tag, reasonid);


--
-- Name: stock_card_line_items_stockcardid_idx; Type: INDEX; Schema: stockmanagement; Owner: postgres
--

CREATE INDEX stock_card_line_items_stockcardid_idx ON stock_card_line_items USING btree (stockcardid);


--
-- Name: stock_event_line_items_stockeventid_idx; Type: INDEX; Schema: stockmanagement; Owner: postgres
--

CREATE INDEX stock_event_line_items_stockeventid_idx ON stock_event_line_items USING btree (stockeventid);


--
-- Name: uk_6uy5au82jp04x5wcg5wgj1j1k; Type: INDEX; Schema: stockmanagement; Owner: postgres
--

CREATE UNIQUE INDEX uk_6uy5au82jp04x5wcg5wgj1j1k ON stock_card_line_item_reasons USING btree (name);


--
-- Name: uniq_stock_card_facility_program_product; Type: INDEX; Schema: stockmanagement; Owner: postgres
--

CREATE UNIQUE INDEX uniq_stock_card_facility_program_product ON stock_cards USING btree (facilityid, programid, orderableid) WHERE (lotid IS NULL);


--
-- Name: uniq_stock_card_facility_program_product_lot; Type: INDEX; Schema: stockmanagement; Owner: postgres
--

CREATE UNIQUE INDEX uniq_stock_card_facility_program_product_lot ON stock_cards USING btree (facilityid, programid, orderableid, lotid) WHERE (lotid IS NOT NULL);


SET search_path = requisition, pg_catalog;

--
-- Name: status_changes check_status_changes; Type: TRIGGER; Schema: requisition; Owner: postgres
--

CREATE CONSTRAINT TRIGGER check_status_changes AFTER INSERT ON status_changes DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE PROCEDURE unique_status_changes();


SET search_path = auth, pg_catalog;

--
-- Name: api_keys api_keys_clientid_fk; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY api_keys
    ADD CONSTRAINT api_keys_clientid_fk FOREIGN KEY (clientid) REFERENCES oauth_client_details(clientid);


--
-- Name: password_reset_tokens fk_la2ts67g4oh2sreayswhox1i6; Type: FK CONSTRAINT; Schema: auth; Owner: postgres
--

ALTER TABLE ONLY password_reset_tokens
    ADD CONSTRAINT fk_la2ts67g4oh2sreayswhox1i6 FOREIGN KEY (userid) REFERENCES auth_users(id);


SET search_path = cce, pg_catalog;

--
-- Name: cce_alert_status_messages cce_alert_status_messages_alertid_fkey; Type: FK CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_alert_status_messages
    ADD CONSTRAINT cce_alert_status_messages_alertid_fkey FOREIGN KEY (alertid) REFERENCES cce_alerts(id);


--
-- Name: cce_alerts cce_alerts_inventoryitemid_fkey; Type: FK CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_alerts
    ADD CONSTRAINT cce_alerts_inventoryitemid_fkey FOREIGN KEY (inventoryitemid) REFERENCES cce_inventory_items(id);


--
-- Name: cce_inventory_items fk_inventory_catalog; Type: FK CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY cce_inventory_items
    ADD CONSTRAINT fk_inventory_catalog FOREIGN KEY (catalogitemid) REFERENCES cce_catalog_items(id);


--
-- Name: jv_commit_property jv_commit_property_commit_fk; Type: FK CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_global_id jv_global_id_owner_id_fk; Type: FK CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_owner_id_fk FOREIGN KEY (owner_id_fk) REFERENCES jv_global_id(global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_commit_fk; Type: FK CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_snapshot jv_snapshot_global_id_fk; Type: FK CONSTRAINT; Schema: cce; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_global_id_fk FOREIGN KEY (global_id_fk) REFERENCES jv_global_id(global_id_pk);


SET search_path = fulfillment, pg_catalog;

--
-- Name: template_parameters fk6p8u7j1vauhmjf0q8axqj3aj4; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY template_parameters
    ADD CONSTRAINT fk6p8u7j1vauhmjf0q8axqj3aj4 FOREIGN KEY (templateid) REFERENCES templates(id);


--
-- Name: status_messages fkou618chqnxfgjmouj7nlemadc; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY status_messages
    ADD CONSTRAINT fkou618chqnxfgjmouj7nlemadc FOREIGN KEY (orderid) REFERENCES orders(id);


--
-- Name: order_file_columns fkqomo9559lvt6qgkgfrmjw49ag; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY order_file_columns
    ADD CONSTRAINT fkqomo9559lvt6qgkgfrmjw49ag FOREIGN KEY (orderfiletemplateid) REFERENCES order_file_templates(id);


--
-- Name: jv_commit_property jv_commit_property_commit_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_global_id jv_global_id_owner_id_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_owner_id_fk FOREIGN KEY (owner_id_fk) REFERENCES jv_global_id(global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_commit_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_snapshot jv_snapshot_global_id_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_global_id_fk FOREIGN KEY (global_id_fk) REFERENCES jv_global_id(global_id_pk);


--
-- Name: order_line_items order_line_items_orderid_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY order_line_items
    ADD CONSTRAINT order_line_items_orderid_fk FOREIGN KEY (orderid) REFERENCES orders(id);


--
-- Name: proof_of_delivery_line_items proof_of_delivery_line_items_proofofdeliveryid_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY proof_of_delivery_line_items
    ADD CONSTRAINT proof_of_delivery_line_items_proofofdeliveryid_fk FOREIGN KEY (proofofdeliveryid) REFERENCES proofs_of_delivery(id);


--
-- Name: proofs_of_delivery proofs_of_delivery_shipmentid_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY proofs_of_delivery
    ADD CONSTRAINT proofs_of_delivery_shipmentid_fk FOREIGN KEY (shipmentid) REFERENCES shipments(id);


--
-- Name: shipment_draft_line_items shipment_draft_line_items_shipmentdraftid_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipment_draft_line_items
    ADD CONSTRAINT shipment_draft_line_items_shipmentdraftid_fk FOREIGN KEY (shipmentdraftid) REFERENCES shipment_drafts(id);


--
-- Name: shipment_drafts shipment_drafts_orderid_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipment_drafts
    ADD CONSTRAINT shipment_drafts_orderid_fk FOREIGN KEY (orderid) REFERENCES orders(id);


--
-- Name: shipment_line_items shipment_line_items_shipment_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipment_line_items
    ADD CONSTRAINT shipment_line_items_shipment_fk FOREIGN KEY (shipmentid) REFERENCES shipments(id);


--
-- Name: shipments shipments_orderid_fk; Type: FK CONSTRAINT; Schema: fulfillment; Owner: postgres
--

ALTER TABLE ONLY shipments
    ADD CONSTRAINT shipments_orderid_fk FOREIGN KEY (orderid) REFERENCES orders(id);


SET search_path = notification, pg_catalog;

--
-- Name: email_verification_tokens email_verification_tokens_usercontactdetailsid_fk; Type: FK CONSTRAINT; Schema: notification; Owner: postgres
--

ALTER TABLE ONLY email_verification_tokens
    ADD CONSTRAINT email_verification_tokens_usercontactdetailsid_fk FOREIGN KEY (usercontactdetailsid) REFERENCES user_contact_details(referencedatauserid);


--
-- Name: notification_messages notification_messages_notificationid_fkey; Type: FK CONSTRAINT; Schema: notification; Owner: postgres
--

ALTER TABLE ONLY notification_messages
    ADD CONSTRAINT notification_messages_notificationid_fkey FOREIGN KEY (notificationid) REFERENCES notifications(id);


SET search_path = referencedata, pg_catalog;

--
-- Name: commodity_types commodity_types_parent; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY commodity_types
    ADD CONSTRAINT commodity_types_parent FOREIGN KEY (parentid) REFERENCES commodity_types(id);


--
-- Name: dispensable_attributes dispensable_attributes_dispensableid_fkey; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY dispensable_attributes
    ADD CONSTRAINT dispensable_attributes_dispensableid_fkey FOREIGN KEY (dispensableid) REFERENCES dispensables(id);


--
-- Name: program_orderables fk1utrvcvl0bmr3l3ysq9fesvtx; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY program_orderables
    ADD CONSTRAINT fk1utrvcvl0bmr3l3ysq9fesvtx FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: supply_lines fk2tcq3p7atk25pe8xmdbuwy2wo; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT fk2tcq3p7atk25pe8xmdbuwy2wo FOREIGN KEY (supplyingfacilityid) REFERENCES facilities(id);


--
-- Name: requisition_groups fk2u2ivdivj2nkctl3e1btgelvg; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_groups
    ADD CONSTRAINT fk2u2ivdivj2nkctl3e1btgelvg FOREIGN KEY (supervisorynodeid) REFERENCES supervisory_nodes(id);


--
-- Name: role_assignments fk2uuqsp7ofjrvkwd7gpgvn9916; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT fk2uuqsp7ofjrvkwd7gpgvn9916 FOREIGN KEY (warehouseid) REFERENCES facilities(id);


--
-- Name: facilities fk2vn7d69cbm7cl3m4rte8cy6ja; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT fk2vn7d69cbm7cl3m4rte8cy6ja FOREIGN KEY (geographiczoneid) REFERENCES geographic_zones(id);


--
-- Name: requisition_group_program_schedules fk3lhot2j862re7kndwhthe7dnt; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT fk3lhot2j862re7kndwhthe7dnt FOREIGN KEY (dropofffacilityid) REFERENCES facilities(id);


--
-- Name: geographic_zones fk3wu6tbyjf7re179s3v57d0hqw; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY geographic_zones
    ADD CONSTRAINT fk3wu6tbyjf7re179s3v57d0hqw FOREIGN KEY (levelid) REFERENCES geographic_levels(id);


--
-- Name: requisition_group_program_schedules fk40dovhydsykbqbs0yg2qkg7n8; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT fk40dovhydsykbqbs0yg2qkg7n8 FOREIGN KEY (requisitiongroupid) REFERENCES requisition_groups(id);


--
-- Name: requisition_group_members fk5dmm5ettanr8rw408jyv4mux0; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_group_members
    ADD CONSTRAINT fk5dmm5ettanr8rw408jyv4mux0 FOREIGN KEY (requisitiongroupid) REFERENCES requisition_groups(id);


--
-- Name: requisition_group_program_schedules fk5yvqwsfj7a21e34vp9rb13ibj; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT fk5yvqwsfj7a21e34vp9rb13ibj FOREIGN KEY (processingscheduleid) REFERENCES processing_schedules(id);


--
-- Name: program_orderables fk65l9b1mrvec9tqosisdkp6clu; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY program_orderables
    ADD CONSTRAINT fk65l9b1mrvec9tqosisdkp6clu FOREIGN KEY (orderabledisplaycategoryid) REFERENCES orderable_display_categories(id);


--
-- Name: role_assignments fk7bq08uarqixbaytuyjtsg45mv; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT fk7bq08uarqixbaytuyjtsg45mv FOREIGN KEY (userid) REFERENCES users(id);


--
-- Name: right_attachments fk7tf8gu3jng8p1xgyt8obnavks; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY right_attachments
    ADD CONSTRAINT fk7tf8gu3jng8p1xgyt8obnavks FOREIGN KEY (rightid) REFERENCES rights(id);


--
-- Name: requisition_group_program_schedules fk81f9bol3noopwf1em9t21e6c6; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_group_program_schedules
    ADD CONSTRAINT fk81f9bol3noopwf1em9t21e6c6 FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: facility_type_approved_products fk8clgdfo4j2nsb6ssxs3u0cp8n; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facility_type_approved_products
    ADD CONSTRAINT fk8clgdfo4j2nsb6ssxs3u0cp8n FOREIGN KEY (facilitytypeid) REFERENCES facility_types(id);


--
-- Name: requisition_group_members fk90lvhcdt9hg4ru1ao38e45x0s; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY requisition_group_members
    ADD CONSTRAINT fk90lvhcdt9hg4ru1ao38e45x0s FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: supported_programs fk986t770e98w262b6ram6m2oi3; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supported_programs
    ADD CONSTRAINT fk986t770e98w262b6ram6m2oi3 FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: role_rights fk9esnupki24cc8i9hwjryvuym3; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY role_rights
    ADD CONSTRAINT fk9esnupki24cc8i9hwjryvuym3 FOREIGN KEY (roleid) REFERENCES roles(id);


--
-- Name: supported_programs fk9qt21xn4mnehgra2y1ajelx51; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supported_programs
    ADD CONSTRAINT fk9qt21xn4mnehgra2y1ajelx51 FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: right_attachments fkago6b65vqo0xapciruk8jqur1; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY right_attachments
    ADD CONSTRAINT fkago6b65vqo0xapciruk8jqur1 FOREIGN KEY (attachmentid) REFERENCES rights(id);


--
-- Name: supply_lines fkbcgrqydf79ingrbb1b8qttp9t; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT fkbcgrqydf79ingrbb1b8qttp9t FOREIGN KEY (supervisorynodeid) REFERENCES supervisory_nodes(id);


--
-- Name: users fkg49ujisk0joauiklj0vlldm35; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fkg49ujisk0joauiklj0vlldm35 FOREIGN KEY (homefacilityid) REFERENCES facilities(id);


--
-- Name: stock_adjustment_reasons fkh9gh9d7vlgco9n7h3daallwd2; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY stock_adjustment_reasons
    ADD CONSTRAINT fkh9gh9d7vlgco9n7h3daallwd2 FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: role_rights fkhawcmr9fx4f9032iygb1xndti; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY role_rights
    ADD CONSTRAINT fkhawcmr9fx4f9032iygb1xndti FOREIGN KEY (rightid) REFERENCES rights(id);


--
-- Name: role_assignments fkhib37s2ph4w22wqdu1iyrf439; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT fkhib37s2ph4w22wqdu1iyrf439 FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: supply_lines fkkg17afgncqqlfht3u37cfl7d6; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supply_lines
    ADD CONSTRAINT fkkg17afgncqqlfht3u37cfl7d6 FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: facilities fkm12nqtk6paxb7b20m5rklm12w; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT fkm12nqtk6paxb7b20m5rklm12w FOREIGN KEY (operatedbyid) REFERENCES facility_operators(id);


--
-- Name: role_assignments fkmhstjposjfpa0m77v89gy0q2b; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT fkmhstjposjfpa0m77v89gy0q2b FOREIGN KEY (supervisorynodeid) REFERENCES supervisory_nodes(id);


--
-- Name: processing_periods fkn4fxuvpiasbtskg8avi5pnff0; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY processing_periods
    ADD CONSTRAINT fkn4fxuvpiasbtskg8avi5pnff0 FOREIGN KEY (processingscheduleid) REFERENCES processing_schedules(id);


--
-- Name: role_assignments fknk908araoyndgd7uwsedn0ddh; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY role_assignments
    ADD CONSTRAINT fknk908araoyndgd7uwsedn0ddh FOREIGN KEY (roleid) REFERENCES roles(id);


--
-- Name: program_orderables fkp2b6lcwnyqul4yi2vnd2vvq50; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY program_orderables
    ADD CONSTRAINT fkp2b6lcwnyqul4yi2vnd2vvq50 FOREIGN KEY (orderableid) REFERENCES orderables(id);


--
-- Name: facilities fkpc0soanvqabccyg5br9aexoc1; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facilities
    ADD CONSTRAINT fkpc0soanvqabccyg5br9aexoc1 FOREIGN KEY (typeid) REFERENCES facility_types(id);


--
-- Name: supervisory_nodes fkpjjkmuhcksc8mhfsnfxf8d9fh; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supervisory_nodes
    ADD CONSTRAINT fkpjjkmuhcksc8mhfsnfxf8d9fh FOREIGN KEY (parentid) REFERENCES supervisory_nodes(id);


--
-- Name: supervisory_nodes fksaovlf1j7vrxvabbiyl1mt37t; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY supervisory_nodes
    ADD CONSTRAINT fksaovlf1j7vrxvabbiyl1mt37t FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: facility_type_approved_products ftap_orderableid_fk; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facility_type_approved_products
    ADD CONSTRAINT ftap_orderableid_fk FOREIGN KEY (orderableid) REFERENCES orderables(id);


--
-- Name: facility_type_approved_products ftap_programid_fk; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY facility_type_approved_products
    ADD CONSTRAINT ftap_programid_fk FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: geographic_zones geographic_zones_parentid_fkey; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY geographic_zones
    ADD CONSTRAINT geographic_zones_parentid_fkey FOREIGN KEY (parentid) REFERENCES geographic_zones(id);


--
-- Name: ideal_stock_amounts isa_commoditytypeid_fk; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY ideal_stock_amounts
    ADD CONSTRAINT isa_commoditytypeid_fk FOREIGN KEY (commoditytypeid) REFERENCES commodity_types(id);


--
-- Name: ideal_stock_amounts isa_facilityid_fk; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY ideal_stock_amounts
    ADD CONSTRAINT isa_facilityid_fk FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: ideal_stock_amounts isa_processingperiodid_fk; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY ideal_stock_amounts
    ADD CONSTRAINT isa_processingperiodid_fk FOREIGN KEY (processingperiodid) REFERENCES processing_periods(id);


--
-- Name: jv_commit_property jv_commit_property_commit_fk; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_global_id jv_global_id_owner_id_fk; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_owner_id_fk FOREIGN KEY (owner_id_fk) REFERENCES jv_global_id(global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_commit_fk; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_snapshot jv_snapshot_global_id_fk; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_global_id_fk FOREIGN KEY (global_id_fk) REFERENCES jv_global_id(global_id_pk);


--
-- Name: lots lots_tradeitemid_fkey; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY lots
    ADD CONSTRAINT lots_tradeitemid_fkey FOREIGN KEY (tradeitemid) REFERENCES trade_items(id);


--
-- Name: orderable_identifiers orderable_identifiers_orderableid_fkey; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY orderable_identifiers
    ADD CONSTRAINT orderable_identifiers_orderableid_fkey FOREIGN KEY (orderableid) REFERENCES orderables(id);


--
-- Name: orderables orderables_dispensableid_fkey; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY orderables
    ADD CONSTRAINT orderables_dispensableid_fkey FOREIGN KEY (dispensableid) REFERENCES dispensables(id);


--
-- Name: right_assignments right_assignments_facilityid_fkey; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY right_assignments
    ADD CONSTRAINT right_assignments_facilityid_fkey FOREIGN KEY (facilityid) REFERENCES facilities(id);


--
-- Name: right_assignments right_assignments_programid_fkey; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY right_assignments
    ADD CONSTRAINT right_assignments_programid_fkey FOREIGN KEY (programid) REFERENCES programs(id);


--
-- Name: right_assignments right_assignments_rightname_fkey; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY right_assignments
    ADD CONSTRAINT right_assignments_rightname_fkey FOREIGN KEY (rightname) REFERENCES rights(name);


--
-- Name: right_assignments right_assignments_userid_fkey; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY right_assignments
    ADD CONSTRAINT right_assignments_userid_fkey FOREIGN KEY (userid) REFERENCES users(id);


--
-- Name: trade_item_classifications trade_item_classifications_trade_items; Type: FK CONSTRAINT; Schema: referencedata; Owner: postgres
--

ALTER TABLE ONLY trade_item_classifications
    ADD CONSTRAINT trade_item_classifications_trade_items FOREIGN KEY (tradeitemid) REFERENCES trade_items(id);


SET search_path = report, pg_catalog;

--
-- Name: jaspertemplate_requiredrights fk_jaspertemplate_requiredrights__jasper_templates; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jaspertemplate_requiredrights
    ADD CONSTRAINT fk_jaspertemplate_requiredrights__jasper_templates FOREIGN KEY (jaspertemplateid) REFERENCES jasper_templates(id);


--
-- Name: jasper_template_parameter_dependencies fk_parameterid_template_parameters; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jasper_template_parameter_dependencies
    ADD CONSTRAINT fk_parameterid_template_parameters FOREIGN KEY (parameterid) REFERENCES template_parameters(id);


--
-- Name: template_parameters fk_qww3p7ho2t5jyutkllrh64khr; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY template_parameters
    ADD CONSTRAINT fk_qww3p7ho2t5jyutkllrh64khr FOREIGN KEY (templateid) REFERENCES jasper_templates(id);


--
-- Name: jaspertemplateparameter_options fkpxphnoksec55h63evgb3obfxq; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jaspertemplateparameter_options
    ADD CONSTRAINT fkpxphnoksec55h63evgb3obfxq FOREIGN KEY (jaspertemplateparameterid) REFERENCES template_parameters(id);


--
-- Name: jasper_templates_report_images jasper_templates_id_fk; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jasper_templates_report_images
    ADD CONSTRAINT jasper_templates_id_fk FOREIGN KEY (jaspertemplateid) REFERENCES jasper_templates(id);


--
-- Name: jv_commit_property jv_commit_property_commit_fk; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_global_id jv_global_id_owner_id_fk; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_owner_id_fk FOREIGN KEY (owner_id_fk) REFERENCES jv_global_id(global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_commit_fk; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_snapshot jv_snapshot_global_id_fk; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_global_id_fk FOREIGN KEY (global_id_fk) REFERENCES jv_global_id(global_id_pk);


--
-- Name: jasper_templates_report_images report_images_id_fk; Type: FK CONSTRAINT; Schema: report; Owner: postgres
--

ALTER TABLE ONLY jasper_templates_report_images
    ADD CONSTRAINT report_images_id_fk FOREIGN KEY (reportimageid) REFERENCES report_images(id);


SET search_path = requisition, pg_catalog;

--
-- Name: requisitions_previous_requisitions fk_10n2ij8p9q2oyfsn3jma3q85n; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisitions_previous_requisitions
    ADD CONSTRAINT fk_10n2ij8p9q2oyfsn3jma3q85n FOREIGN KEY (previousrequisitionid) REFERENCES requisitions(id);


--
-- Name: columns_maps fk_1k2xr4hbgipw4126xw4pgy70e; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY columns_maps
    ADD CONSTRAINT fk_1k2xr4hbgipw4126xw4pgy70e FOREIGN KEY (requisitiontemplateid) REFERENCES requisition_templates(id);


--
-- Name: requisitions fk_1ytg3dn9rcjam5mv9h6u1x14e; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisitions
    ADD CONSTRAINT fk_1ytg3dn9rcjam5mv9h6u1x14e FOREIGN KEY (templateid) REFERENCES requisition_templates(id);


--
-- Name: requisition_line_items fk_4sg1naierwgt9avsjcm76a2yl; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisition_line_items
    ADD CONSTRAINT fk_4sg1naierwgt9avsjcm76a2yl FOREIGN KEY (requisitionid) REFERENCES requisitions(id);


--
-- Name: stock_adjustments fk_9nqi8imo7ty6jafeijhviynrt; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY stock_adjustments
    ADD CONSTRAINT fk_9nqi8imo7ty6jafeijhviynrt FOREIGN KEY (requisitionlineitemid) REFERENCES requisition_line_items(id);


--
-- Name: columns_maps fk_a6nm2s34wa449q2i3crk3mlc0; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY columns_maps
    ADD CONSTRAINT fk_a6nm2s34wa449q2i3crk3mlc0 FOREIGN KEY (requisitioncolumnoptionid) REFERENCES available_requisition_column_options(id);


--
-- Name: available_requisition_column_sources fk_au3xmstd4bn77xeia175ftmuc; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY available_requisition_column_sources
    ADD CONSTRAINT fk_au3xmstd4bn77xeia175ftmuc FOREIGN KEY (columnid) REFERENCES available_requisition_columns(id);


--
-- Name: available_products fk_b8078votirpsmh2cpuvm0oull; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY available_products
    ADD CONSTRAINT fk_b8078votirpsmh2cpuvm0oull FOREIGN KEY (requisitionid) REFERENCES requisitions(id);


--
-- Name: available_requisition_column_options fk_gwot77t2t7y1am93r3qvuyy7u; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY available_requisition_column_options
    ADD CONSTRAINT fk_gwot77t2t7y1am93r3qvuyy7u FOREIGN KEY (columnid) REFERENCES available_requisition_columns(id);


--
-- Name: status_messages fk_hp6wryw9250cf3jhceddvmn5b; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY status_messages
    ADD CONSTRAINT fk_hp6wryw9250cf3jhceddvmn5b FOREIGN KEY (requisitionid) REFERENCES requisitions(id);


--
-- Name: columns_maps fk_k7b90206ee1t5nl8iea8q0ij8; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY columns_maps
    ADD CONSTRAINT fk_k7b90206ee1t5nl8iea8q0ij8 FOREIGN KEY (requisitioncolumnid) REFERENCES available_requisition_columns(id);


--
-- Name: previous_adjusted_consumptions fk_ofrpexcgp8i7ppwit5kbs0ryr; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY previous_adjusted_consumptions
    ADD CONSTRAINT fk_ofrpexcgp8i7ppwit5kbs0ryr FOREIGN KEY (requisitionlineitemid) REFERENCES requisition_line_items(id);


--
-- Name: jasper_template_parameter_dependencies fk_parameterid_template_parameters; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jasper_template_parameter_dependencies
    ADD CONSTRAINT fk_parameterid_template_parameters FOREIGN KEY (parameterid) REFERENCES template_parameters(id);


--
-- Name: requisitions_previous_requisitions fk_pg6tsrnawyhqelfg6tb6fq4f5; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisitions_previous_requisitions
    ADD CONSTRAINT fk_pg6tsrnawyhqelfg6tb6fq4f5 FOREIGN KEY (requisitionid) REFERENCES requisitions(id);


--
-- Name: template_parameters fk_qww3p7ho2t5jyutkllrh64khr; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY template_parameters
    ADD CONSTRAINT fk_qww3p7ho2t5jyutkllrh64khr FOREIGN KEY (templateid) REFERENCES jasper_templates(id);


--
-- Name: status_messages fk_status_messages_status_change_id; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY status_messages
    ADD CONSTRAINT fk_status_messages_status_change_id FOREIGN KEY (statuschangeid) REFERENCES status_changes(id);


--
-- Name: stock_adjustment_reasons fk_stock_adjustment_reasons_requisitions; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY stock_adjustment_reasons
    ADD CONSTRAINT fk_stock_adjustment_reasons_requisitions FOREIGN KEY (requisitionid) REFERENCES requisitions(id);


--
-- Name: jaspertemplateparameter_options fkpxphnoksec55h63evgb3obfxq; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jaspertemplateparameter_options
    ADD CONSTRAINT fkpxphnoksec55h63evgb3obfxq FOREIGN KEY (jaspertemplateparameterid) REFERENCES template_parameters(id);


--
-- Name: jv_commit_property jv_commit_property_commit_fk; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jv_commit_property
    ADD CONSTRAINT jv_commit_property_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_global_id jv_global_id_owner_id_fk; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jv_global_id
    ADD CONSTRAINT jv_global_id_owner_id_fk FOREIGN KEY (owner_id_fk) REFERENCES jv_global_id(global_id_pk);


--
-- Name: jv_snapshot jv_snapshot_commit_fk; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_commit_fk FOREIGN KEY (commit_fk) REFERENCES jv_commit(commit_pk);


--
-- Name: jv_snapshot jv_snapshot_global_id_fk; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY jv_snapshot
    ADD CONSTRAINT jv_snapshot_global_id_fk FOREIGN KEY (global_id_fk) REFERENCES jv_global_id(global_id_pk);


--
-- Name: requisition_template_assignments req_tmpl_asgmt_req_tmpl_fkey; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisition_template_assignments
    ADD CONSTRAINT req_tmpl_asgmt_req_tmpl_fkey FOREIGN KEY (templateid) REFERENCES requisition_templates(id);


--
-- Name: requisition_permission_strings requisition_permission_strings_requisitionid_fkey; Type: FK CONSTRAINT; Schema: requisition; Owner: postgres
--

ALTER TABLE ONLY requisition_permission_strings
    ADD CONSTRAINT requisition_permission_strings_requisitionid_fkey FOREIGN KEY (requisitionid) REFERENCES requisitions(id);


SET search_path = stockmanagement, pg_catalog;

--
-- Name: physical_inventory_line_item_adjustments fk_phys_inv_adj_phys_inv_item; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY physical_inventory_line_item_adjustments
    ADD CONSTRAINT fk_phys_inv_adj_phys_inv_item FOREIGN KEY (physicalinventorylineitemid) REFERENCES physical_inventory_line_items(id);


--
-- Name: physical_inventory_line_item_adjustments fk_phys_inv_adj_reason; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY physical_inventory_line_item_adjustments
    ADD CONSTRAINT fk_phys_inv_adj_reason FOREIGN KEY (reasonid) REFERENCES stock_card_line_item_reasons(id);


--
-- Name: physical_inventory_line_item_adjustments fk_phys_inv_adj_stock_card_item; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY physical_inventory_line_item_adjustments
    ADD CONSTRAINT fk_phys_inv_adj_stock_card_item FOREIGN KEY (stockcardlineitemid) REFERENCES stock_card_line_items(id);


--
-- Name: physical_inventory_line_item_adjustments fk_phys_inv_adj_stock_event_item; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY physical_inventory_line_item_adjustments
    ADD CONSTRAINT fk_phys_inv_adj_stock_event_item FOREIGN KEY (stockeventlineitemid) REFERENCES stock_event_line_items(id);


--
-- Name: physical_inventories physical_inventories_stockeventid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY physical_inventories
    ADD CONSTRAINT physical_inventories_stockeventid_fkey FOREIGN KEY (stockeventid) REFERENCES stock_events(id);


--
-- Name: physical_inventory_line_items physical_inventory_line_items_physicalinventoryid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY physical_inventory_line_items
    ADD CONSTRAINT physical_inventory_line_items_physicalinventoryid_fkey FOREIGN KEY (physicalinventoryid) REFERENCES physical_inventories(id);


--
-- Name: stock_card_fields stock_card_fields_availablestockcardfieldsid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_fields
    ADD CONSTRAINT stock_card_fields_availablestockcardfieldsid_fkey FOREIGN KEY (availablestockcardfieldsid) REFERENCES available_stock_card_fields(id);


--
-- Name: stock_card_fields stock_card_fields_stockcardtemplateid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_fields
    ADD CONSTRAINT stock_card_fields_stockcardtemplateid_fkey FOREIGN KEY (stockcardtemplateid) REFERENCES stock_card_templates(id);


--
-- Name: stock_card_line_item_fields stock_card_line_item_fields_availablestockcardlineitemfiel_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_item_fields
    ADD CONSTRAINT stock_card_line_item_fields_availablestockcardlineitemfiel_fkey FOREIGN KEY (availablestockcardlineitemfieldsid) REFERENCES available_stock_card_line_item_fields(id);


--
-- Name: stock_card_line_item_fields stock_card_line_item_fields_stockcardtemplateid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_item_fields
    ADD CONSTRAINT stock_card_line_item_fields_stockcardtemplateid_fkey FOREIGN KEY (stockcardtemplateid) REFERENCES stock_card_templates(id);


--
-- Name: stock_card_line_item_reason_tags stock_card_line_item_reason_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_item_reason_tags
    ADD CONSTRAINT stock_card_line_item_reason_fkey FOREIGN KEY (reasonid) REFERENCES stock_card_line_item_reasons(id);


--
-- Name: stock_card_line_items stock_card_line_items_destinationid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_items
    ADD CONSTRAINT stock_card_line_items_destinationid_fkey FOREIGN KEY (destinationid) REFERENCES nodes(id);


--
-- Name: stock_card_line_items stock_card_line_items_origineventid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_items
    ADD CONSTRAINT stock_card_line_items_origineventid_fkey FOREIGN KEY (origineventid) REFERENCES stock_events(id);


--
-- Name: stock_card_line_items stock_card_line_items_reasonid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_items
    ADD CONSTRAINT stock_card_line_items_reasonid_fkey FOREIGN KEY (reasonid) REFERENCES stock_card_line_item_reasons(id);


--
-- Name: stock_card_line_items stock_card_line_items_sourceid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_items
    ADD CONSTRAINT stock_card_line_items_sourceid_fkey FOREIGN KEY (sourceid) REFERENCES nodes(id);


--
-- Name: stock_card_line_items stock_card_line_items_stockcardid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_card_line_items
    ADD CONSTRAINT stock_card_line_items_stockcardid_fkey FOREIGN KEY (stockcardid) REFERENCES stock_cards(id);


--
-- Name: stock_cards stock_cards_origineventid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_cards
    ADD CONSTRAINT stock_cards_origineventid_fkey FOREIGN KEY (origineventid) REFERENCES stock_events(id);


--
-- Name: stock_event_line_items stock_event_line_items_stockeventid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY stock_event_line_items
    ADD CONSTRAINT stock_event_line_items_stockeventid_fkey FOREIGN KEY (stockeventid) REFERENCES stock_events(id);


--
-- Name: valid_destination_assignments valid_destination_assignments_nodeid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY valid_destination_assignments
    ADD CONSTRAINT valid_destination_assignments_nodeid_fkey FOREIGN KEY (nodeid) REFERENCES nodes(id);


--
-- Name: valid_reason_assignments valid_reason_assignments_reasonid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY valid_reason_assignments
    ADD CONSTRAINT valid_reason_assignments_reasonid_fkey FOREIGN KEY (reasonid) REFERENCES stock_card_line_item_reasons(id);


--
-- Name: valid_source_assignments valid_source_assignments_nodeid_fkey; Type: FK CONSTRAINT; Schema: stockmanagement; Owner: postgres
--

ALTER TABLE ONLY valid_source_assignments
    ADD CONSTRAINT valid_source_assignments_nodeid_fkey FOREIGN KEY (nodeid) REFERENCES nodes(id);


--
-- PostgreSQL database dump complete
--
