create or replace function function1 (date fecha) return varchar2
    is vnombre;

    de_valor_monto number;
    valor varchar2(50);
    porcentaje varchar2(20); --Si es monto resto al interes

/*Si es porcentaje multiplico
valor cliente , valor_banco
valor del interes*/

    begin

        null;

/*
        IF frech.s_tipo_monto = VALOR THEN
        IF frech.de_valor > frech.de_valor_ic THEN
        frech.de_valor_banco = frech.de_valor_ic
         ELSE
         frech.de_valor_banco = frech.de_valor
         END IF
         frech.de_valor_cliente = frech.de_valor_ic - frech.de_valor
        ELSE
         frech.de_valor_banco = frech.de_valor_ic * frech.de_valor
         frech.de_valor_cliente = frech.de_valor_ic - ( frech.de_valor_ic * frech.de_valor )
        END IF
*/

    end function1;

