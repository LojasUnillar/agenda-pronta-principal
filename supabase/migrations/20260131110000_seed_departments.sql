DO $$
DECLARE v_count integer;
BEGIN -- Insert Departments based on departments_icons.dart
INSERT INTO public.tb_departamento (code, name, active)
VALUES ('almoxarifado', 'Almoxarifado', true),
    ('calcados', 'Calçados', true),
    ('celular', 'Celular', true),
    ('construcao', 'Material de Construção', true),
    ('cosmeticos', 'Cosméticos', true),
    ('bolsas', 'Bolsas e Acessórios', true),
    ('infantil', 'Infantil', true),
    ('moveis', 'Móveis', true),
    ('eletros', 'Eletrodomésticos', true),
    ('motopecas', 'Motopeças', true),
    ('utilidades', 'Utilidades Domésticas', true),
    ('carros', 'Automóvel', true) ON CONFLICT (code) DO NOTHING;
GET DIAGNOSTICS v_count = ROW_COUNT;
RAISE NOTICE 'Departamentos inseridos: %',
v_count;
END $$;