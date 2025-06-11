BEGIN;

DELETE FROM public."__EFMigrationsHistory";

INSERT INTO public."__EFMigrationsHistory" ("migration_id", "product_version")
VALUES ('20250408172603_Initial', '9.0.3');

COMMIT;