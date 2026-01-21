CREATE TABLE organization (
    id              VARCHAR(50) PRIMARY KEY,
    name            VARCHAR(255) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE department (
    id              VARCHAR(50) PRIMARY KEY,
    organization_id VARCHAR(50) NOT NULL,
    name            VARCHAR(255) NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_dept_org
        FOREIGN KEY (organization_id)
        REFERENCES organization(id)
);


CREATE TABLE document (
    id              UUID PRIMARY KEY,
    doc_type        VARCHAR(20) NOT NULL,
    -- DEN | DI

    title           VARCHAR(500) NOT NULL,
    symbol          VARCHAR(100),
    issued_date     DATE,
    due_date        DATE,

    status          VARCHAR(30) NOT NULL,
    -- DRAFT | IN_PROGRESS | COMPLETED | ARCHIVED

    organization_id VARCHAR(50) NOT NULL,
    department_id   VARCHAR(50),

    created_by      UUID NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_doc_org
        FOREIGN KEY (organization_id)
        REFERENCES organization(id),

    CONSTRAINT fk_doc_dept
        FOREIGN KEY (department_id)
        REFERENCES department(id)
);

CREATE TABLE document_file (
    id              UUID PRIMARY KEY,
    document_id     UUID NOT NULL,
    file_name       VARCHAR(255) NOT NULL,
    file_path       TEXT NOT NULL,
    file_type       VARCHAR(20),
    uploaded_by     UUID NOT NULL,
    uploaded_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_file_doc
        FOREIGN KEY (document_id)
        REFERENCES document(id)
        ON DELETE CASCADE
);

CREATE TABLE document_flow (
    id              UUID PRIMARY KEY,
    document_id     UUID NOT NULL,
    from_user       UUID,
    to_user         UUID NOT NULL,

    action          VARCHAR(50) NOT NULL,
    -- CREATE | TRANSFER | PROCESS | COMPLETE | RECALL

    note            TEXT,
    is_opened       BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_flow_doc
        FOREIGN KEY (document_id)
        REFERENCES document(id)
        ON DELETE CASCADE
);

CREATE TABLE folder (
    id              UUID PRIMARY KEY,
    code            VARCHAR(100),
    title           VARCHAR(255) NOT NULL,

    organization_id VARCHAR(50) NOT NULL,
    department_id   VARCHAR(50),

    status          VARCHAR(30) NOT NULL,
    -- OPEN | SUBMITTED | RECEIVED | RETURNED

    created_by      UUID NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_folder_org
        FOREIGN KEY (organization_id)
        REFERENCES organization(id),

    CONSTRAINT fk_folder_dept
        FOREIGN KEY (department_id)
        REFERENCES department(id)
);

CREATE TABLE folder_document (
    id              UUID PRIMARY KEY,
    folder_id       UUID NOT NULL,
    document_id     UUID NOT NULL,
    added_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_fd_folder
        FOREIGN KEY (folder_id)
        REFERENCES folder(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_fd_doc
        FOREIGN KEY (document_id)
        REFERENCES document(id)
        ON DELETE CASCADE,

    CONSTRAINT uq_folder_document UNIQUE (folder_id, document_id)
);

CREATE TABLE task (
    id              UUID PRIMARY KEY,
    document_id     UUID,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    assigned_to     UUID NOT NULL,
    due_date        DATE,
    status          VARCHAR(30) NOT NULL,
    -- TODO | DOING | DONE | OVERDUE

    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_task_doc
        FOREIGN KEY (document_id)
        REFERENCES document(id)
);

CREATE TABLE task_log (
    id              UUID PRIMARY KEY,
    task_id         UUID NOT NULL,
    action          VARCHAR(50) NOT NULL,
    note            TEXT,
    created_by      UUID NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_tasklog_task
        FOREIGN KEY (task_id)
        REFERENCES task(id)
        ON DELETE CASCADE
);


CREATE INDEX idx_doc_org ON document(organization_id);
CREATE INDEX idx_doc_dept ON document(department_id);
CREATE INDEX idx_doc_status ON document(status);
CREATE INDEX idx_doc_due ON document(due_date);

CREATE INDEX idx_flow_doc ON document_flow(document_id);
CREATE INDEX idx_flow_to_user ON document_flow(to_user);

CREATE INDEX idx_task_assigned ON task(assigned_to);
CREATE INDEX idx_task_due ON task(due_date);
