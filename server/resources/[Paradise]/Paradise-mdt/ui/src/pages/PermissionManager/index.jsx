import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import {
	Grid,
	TextField,
	InputAdornment,
	IconButton,
	MenuItem,
	Select,
	Chip,
	FormControl,
	InputLabel,
	Input,
	Box,
	Paper,
} from '@mui/material';
import { makeStyles } from '@mui/styles';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { toast } from 'react-toastify';

import { Loader, Modal } from '../../components';
import Grade from './components/Grade';
import Nui from '../../util/Nui';
import { usePermissions } from '../../hooks';

const useStyles = makeStyles((theme) => ({
	wrapper: {
		padding: 10,
		height: '100%',
	},
	paper: {
		height: '100%',
		maxHeight: '100%',
	},
	search: {},
	officers: {
		flexGrow: 1,
		overflowX: 'hidden',
		overflowY: 'auto',
		maxHeight: '100%',
	},
	editorField: {
		marginBottom: 10,
	},
	permissionField: {
		marginBottom: 10,
		marginTop: 10,
	},
	inner: {
		display: 'flex',
		flexDirection: 'column',
		padding: '10px 5px 10px 5px',
		height: '100%',
	}
}));

export default ({ job = 'system' }) => {
	const classes = useStyles();
	const hasPerm = usePermissions();
	const myJob = useSelector(state => state.app.govJob);
	const governmentJobs = useSelector(state => state.data.data.governmentJobs);
	const [selectedJob, setSelectedJob] = useState(job == 'system' ? myJob.Id : job);
	const allJobData = useSelector(state => state.data.data.governmentJobsData);
	const availablePermissions = useSelector(state => state.data.data.permissions);

	const [jobData, setJobData] = useState(allJobData?.[selectedJob]);
	const [loading, setLoading] = useState(false);
	const [search, setSearch] = useState('');
	const [workplace, setWorkplace] = useState(jobData.Workplaces[0].Id);
	const [filtered, setFiltered] = useState(Array());

	const [pendingPermissions, setPendingPermissions] = useState(Array());
	const [editingOpen, setEditingOpen] = useState(false);
	const [editingPermissions, setEditingPermissions] = useState(null);

	useEffect(() => {
		setJobData(allJobData?.[selectedJob]);
		setWorkplace(allJobData?.[selectedJob]?.Workplaces?.[0].Id);
	}, [selectedJob]);

	useEffect(() => {
		setJobData(allJobData?.[selectedJob]);
	}, [allJobData]);

	useEffect(() => {
		let rgx = new RegExp(search, 'i');
		setFiltered(jobData.Workplaces.find(w => w.Id == workplace)?.Grades?.filter(g => g.Name.match(rgx)) ?? Array());
	}, [jobData, search, workplace]);

	const onSelect = (grade) => {
		setPendingPermissions(
			Object.keys(grade.Permissions)
				.filter(perm => grade.Permissions[perm])
		);
		setEditingPermissions(grade);
		setEditingOpen(true);
	};

	const onClose = () => {
		setEditingOpen(false);
	};

	const onPermissionsChange = (e) => {
		setPendingPermissions([...e.target.value]);
	};

	const onSavePermissions = async (e) => {
		e.preventDefault();
		onClose();
		setLoading(true);

		let newPermissions = {};
		for (const permission of pendingPermissions) {
			newPermissions[permission] = true;
		};

		try {
			let res = await (
				await Nui.send('Update', {
					type: 'jobPermissions',
					JobId: (job == 'system' ? selectedJob : myJob.Id),
					WorkplaceId: workplace,
					GradeId: editingPermissions.Id,
					UpdatedPermissions: newPermissions,
				})
			).json();
			if (res) {
				toast.success('Permissions Updated');
			} else toast.error('Failed to Update Permissions');
		} catch (err) {
			console.log(err);
			toast.error('Failed to Update Permissions');
		}

		setLoading(false);
	};

	const isSysAdmin = hasPerm(true);

	return (
		<div className={classes.wrapper}>

			<Grid container style={{ height: '100%' }}>
				<Grid item xs={12} style={{ height: '100%' }}>
					<Paper elevation={3} className={classes.paper}>
						{loading ? (
							<Loader static text="Loading" />
						) : (
							<>
								<div className={classes.inner}>
									<div className={classes.search}>
										<Grid container spacing={1}>
											{job == 'system' && <Grid item xs={4}>
												<TextField
													select
													fullWidth
													label="Agency"
													variant="standard"
													className={classes.editorField}
													value={selectedJob}
													onChange={(e) => setSelectedJob(e.target.value)}
												>
													{governmentJobs.map(j => (
														<MenuItem key={j} value={j}>
															{allJobData[j]?.Name ?? 'Unknown'}
														</MenuItem>
													))}
												</TextField>
											</Grid>}
											<Grid item xs={job == 'system' ? 4 : 6}>
												<TextField
													select
													fullWidth
													label="Department"
													variant="standard"
													className={classes.editorField}
													value={workplace}
													onChange={(e) => setWorkplace(e.target.value)}
												>
													{jobData.Workplaces.map(w => (
														<MenuItem key={w.Id} value={w.Id}>
															{w.Name}
														</MenuItem>
													))}
												</TextField>
											</Grid>
											<Grid item xs={job == 'system' ? 4 : 6}>
												<TextField
													fullWidth
													label="Search"
													variant="standard"
													value={search}
													onChange={(e) =>
														setSearch(e.target.value)
													}
													InputProps={{
														endAdornment: (
															<InputAdornment position="end">
																{search != '' && (
																	<IconButton
																		type="button"
																		onClick={() =>
																			setSearch('')
																		}
																	>
																		<FontAwesomeIcon
																			icon={[
																				'fas',
																				'xmark',
																			]}
																		/>
																	</IconButton>
																)}
															</InputAdornment>
														),
													}}
												/>
											</Grid>
										</Grid>
									</div>
									<div className={classes.officers}>
										{filtered
											.sort((a, b) => a.Level - b.Level)
											.map((grade, k) => {
												return (
													<Grade key={k} grade={grade} onClick={() => onSelect(grade)} />
												);
											})}
									</div>
								</div>
							</>
						)}

					</Paper>
				</Grid>
			</Grid >

			<Modal
				open={editingOpen}
				maxWidth="md"
				title={`Update ${jobData?.Workplaces?.find(w => w.Id == workplace)?.Name} - ${editingPermissions?.Name}`}
				onSubmit={onSavePermissions}
				onClose={onClose}
			>
				<FormControl fullWidth className={classes.permissionField}>
					<InputLabel>
						Rank Permissions
					</InputLabel>
					<Select
						multiple
						fullWidth
						value={pendingPermissions}
						onChange={onPermissionsChange}
						input={
							<Input fullWidth label="Rank Permissions" />
						}
						renderValue={(selected) => (
							<Box style={{ display: 'flex', flexWrap: 'wrap' }}>
								{selected.sort().map((value) => (
									<Chip
										size="small"
										key={value}
										label={availablePermissions[value]?.name ?? 'Unknown'}
										style={{ margin: 2 }}
									/>
								))}
							</Box>
						)}
					>
						{Object.keys(availablePermissions)
							.filter(perm => {
								const data = availablePermissions[perm];
								return (data && (!data.restrict || data.restrict.job === selectedJob));
							}).sort().map(perm => (
								<MenuItem key={`perm-${perm}`} value={perm}>
									{availablePermissions[perm]?.name}{(isSysAdmin && availablePermissions[perm]?.restrict?.job) ? ` - ${allJobData?.[availablePermissions[perm]?.restrict?.job]?.Name}` : ''}
								</MenuItem>
							)
							)}
					</Select>
				</FormControl>
			</Modal>
		</div >
	);
};
