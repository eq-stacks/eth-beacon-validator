# Validator "Effectiveness"

**Validator Effectiveness** is a construct of the beacon chain explorer.

https://github.com/gobitfly/eth2-beaconchain-explorer/blob/b6fd66a7396cdc5ca7993600840b8c8990d4c34b/handlers/api.go#L606-L618
https://bisontrails.co/eth2-insights-validator-effectiveness/

```
SELECT aa.validatorindex, validators.pubkey, COALESCE(
		AVG(1 + inclusionslot - COALESCE((
			SELECT MIN(slot)
			FROM blocks
			WHERE slot > aa.attesterslot AND blocks.status = '1'
		), 0)
	), 0)::float AS attestation_efficiency
	FROM attestation_assignments_p aa
	INNER JOIN blocks ON blocks.slot = aa.inclusionslot AND blocks.status <> '3'
	INNER JOIN validators ON validators.validatorindex = aa.validatorindex
	WHERE aa.week >= $1 / 1575 AND aa.epoch > $1 AND (validators.validatorindex = ANY($2)) AND aa.inclusionslot > 0
	GROUP BY aa.validatorindex, validators.pubkey
	ORDER BY aa.validatorindex
```

